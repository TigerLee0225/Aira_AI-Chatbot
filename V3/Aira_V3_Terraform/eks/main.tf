provider "aws" {
  region = var.aws_region
}

# 🔹 NAT Gateway 생성
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id_1  # 퍼블릭 서브넷 사용
}

# 🔹 프라이빗 서브넷의 라우트 테이블 설정
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# 🔹 프라이빗 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

# 🔹 EKS 클러스터 보안 그룹
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # EKS API 서버 (노드가 443 포트로 접근 가능)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 보안상 내부 VPC CIDR로 제한하는 것이 좋음
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EKS 클러스터 생성
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = concat(
      [var.public_subnet_id_1, var.public_subnet_id_2],
      var.private_subnet_ids
    )
    
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }
}

# 🔹 퍼블릭 노드 보안 그룹
resource "aws_security_group" "public_node_sg" {
  name        = "eks-public-node-sg"
  description = "Security group for EKS public nodes"
  vpc_id      = var.vpc_id

  # NodePort 서비스용 인바운드 규칙
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow 30080 from anywhere for NodePort services"
  }

  # 기존 클러스터 통신을 위한 규칙
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster_sg.id]
    description     = "Allow all traffic from EKS cluster security group"
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-public-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# 🔹 퍼블릭 노드 그룹
resource "aws_eks_node_group" "public_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "public-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = [var.public_subnet_id_1, var.public_subnet_id_2]
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.public_node_group_desired_size
    min_size     = var.public_node_group_min_size
    max_size     = var.public_node_group_max_size
  }

  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = [aws_security_group.eks_cluster_sg.id, aws_security_group.public_node_sg.id]
  }

  tags = var.public_node_group_tags
}

# 🔹 프라이빗 노드 그룹
resource "aws_eks_node_group" "private_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "private-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.private_node_group_desired_size
    min_size     = var.private_node_group_min_size
    max_size     = var.private_node_group_max_size
  }

  update_config {
    max_unavailable = var.max_unavailable_nodes
  }

  tags = var.private_node_group_tags
}

# 🔹 Frontend ALB
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]
  enable_deletion_protection = false

  tags = {
    Name = "Frontend ALB"
  }
}

# 🔹 Backend ALB
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]
  enable_deletion_protection = false

  tags = {
    Name = "Backend ALB"
  }
}

# 🔹 GPT Worker ALB
resource "aws_lb" "gpt_worker_alb" {
  name               = "gpt-worker-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gpt_worker_alb_sg.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]
  enable_deletion_protection = false

  tags = {
    Name = "GPT Worker ALB"
  }
}

# 🔹 Frontend ALB Listener
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# 🔹 Backend ALB Listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# 🔹 GPT Worker ALB Listener
resource "aws_lb_listener" "gpt_worker_listener" {
  load_balancer_arn = aws_lb.gpt_worker_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gpt_worker_tg.arn
  }
}

# ALB Target Groups
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "gpt_worker_tg" {
  name        = "gpt-worker-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}


# 🔹 Frontend ALB Security Group
resource "aws_security_group" "frontend_alb_sg" {
  name   = "frontend-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 Backend ALB Security Group
resource "aws_security_group" "backend_alb_sg" {
  name   = "backend-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 GPT Worker ALB Security Group
resource "aws_security_group" "gpt_worker_alb_sg" {
  name   = "gpt-worker-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 GPT Request Queue (FIFO)
resource "aws_sqs_queue" "gpt_request_queue" {
  name                        = "${var.cluster_name}-gpt-request-queue.fifo"  # 클러스터 이름을 prefix로 추가
  fifo_queue                  = true
  content_based_deduplication = false
  visibility_timeout_seconds  = 60
  receive_wait_time_seconds   = 20
  message_retention_seconds   = 345600
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.gpt_request_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "gpt-request-queue"
    Environment = var.environment
  }
}

# 🔹 GPT Request DLQ (FIFO)
resource "aws_sqs_queue" "gpt_request_dlq" {
  name                      = "${var.cluster_name}-gpt-request-dlq.fifo"
  fifo_queue                = true
  message_retention_seconds = 1209600

  tags = {
    Name        = "gpt-request-dlq"
    Environment = var.environment
  }
}

# 🔹 GPT Response Queue (FIFO)
resource "aws_sqs_queue" "gpt_response_queue" {
  name                        = "${var.cluster_name}-gpt-response-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = false
  visibility_timeout_seconds  = 60
  receive_wait_time_seconds   = 20
  message_retention_seconds   = 345600
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.gpt_response_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "gpt-response-queue"
    Environment = var.environment
  }
}

# 🔹 GPT Response DLQ (FIFO)
resource "aws_sqs_queue" "gpt_response_dlq" {
  name                      = "${var.cluster_name}-gpt-response-dlq.fifo"
  fifo_queue                = true
  message_retention_seconds = 1209600

  tags = {
    Name        = "gpt-response-dlq"
    Environment = var.environment
  }
}

# 🔹 Queue URLs 및 ARNs 출력
output "gpt_request_queue_url" {
  description = "The URL of the GPT request queue"
  value       = aws_sqs_queue.gpt_request_queue.url
}

output "gpt_request_queue_arn" {
  description = "The ARN of the GPT request queue"
  value       = aws_sqs_queue.gpt_request_queue.arn
}

output "gpt_request_dlq_url" {
  description = "The URL of the GPT request DLQ"
  value       = aws_sqs_queue.gpt_request_dlq.url
}

output "gpt_response_queue_url" {
  description = "The URL of the GPT response queue"
  value       = aws_sqs_queue.gpt_response_queue.url
}

output "gpt_response_queue_arn" {
  description = "The ARN of the GPT response queue"
  value       = aws_sqs_queue.gpt_response_queue.arn
}

output "gpt_response_dlq_url" {
  description = "The URL of the GPT response DLQ"
  value       = aws_sqs_queue.gpt_response_dlq.url
}

