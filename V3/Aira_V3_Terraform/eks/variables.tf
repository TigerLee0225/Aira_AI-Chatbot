# 🔹 AWS 기본 설정
variable "aws_region" {
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# 🔹 서브넷 설정
variable "public_subnet_id_1" {
  description = "퍼블릭 서브넷 리스트"
  type        = string
}

# 🔹 서브넷 설정
variable "public_subnet_id_2" {
  description = "퍼블릭 서브넷 리스트"
  type        = string
}

variable "private_subnet_ids" {
  description = "프라이빗 서브넷 리스트"
  type        = list(string)
}

# 🔹 IAM Role 설정
variable "eks_cluster_role_arn" {
  description = "EKS 클러스터용 IAM Role ARN"
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS 노드 그룹용 IAM Role ARN"
  type        = string
}

# 🔹 EC2 Key Pair
variable "ec2_ssh_key" {
  description = "EC2 SSH 접속용 키페어 이름"
  type        = string
  default     = "Aira-Key"
}

# 🔹 EKS 클러스터 설정
variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "Aira_cluster"
}

variable "endpoint_private_access" {
  description = "EKS 프라이빗 엔드포인트 활성화 여부"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "EKS 퍼블릭 엔드포인트 활성화 여부"
  type        = bool
  default     = false
}

# 🔹 노드 그룹 설정
variable "node_instance_types" {
  description = "EKS 노드 인스턴스 타입"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "public_node_group_desired_size" {
  description = "퍼블릭 노드 그룹 원하는 크기"
  type        = number
  default     = 2
}

variable "public_node_group_min_size" {
  description = "퍼블릭 노드 그룹 최소 크기"
  type        = number
  default     = 1
}

variable "public_node_group_max_size" {
  description = "퍼블릭 노드 그룹 최대 크기"
  type        = number
  default     = 3
}

variable "private_node_group_desired_size" {
  description = "프라이빗 노드 그룹 원하는 크기"
  type        = number
  default     = 2
}

variable "private_node_group_min_size" {
  description = "프라이빗 노드 그룹 최소 크기"
  type        = number
  default     = 1
}

variable "private_node_group_max_size" {
  description = "프라이빗 노드 그룹 최대 크기"
  type        = number
  default     = 3
}

variable "max_unavailable_nodes" {
  description = "업데이트 시 최대 사용 불가능 노드 수"
  type        = number
  default     = 1
}

variable "public_node_group_tags" {
  description = "퍼블릭 노드 그룹 태그"
  type        = map(string)
  default     = {
    Name = "eks-public-node-group"
  }
}

variable "private_node_group_tags" {
  description = "프라이빗 노드 그룹 태그"
  type        = map(string)
  default     = {
    Name = "eks-private-node-group"
  }
}

variable "environment" {
  description = "환경 구분 (예: dev, prod)"
  type        = string
  default     = "dev"
}