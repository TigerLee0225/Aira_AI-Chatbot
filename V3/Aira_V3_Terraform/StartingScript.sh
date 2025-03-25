#!/bin/bash

# ★ 사용자 설정: 아래 변수에 본인의 AWS 자격증명을 입력하세요.
AWS_ACCESS_KEY_ID="AKIA2UC27UYBCIK6VPQH"
AWS_SECRET_ACCESS_KEY="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"
AWS_DEFAULT_REGION="ap-northeast-2"

# 🎯 AWS CLI 및 Terraform 설치 스크립트
echo "🚀 시스템 패키지 업데이트..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip curl git

# 🔹 AWS CLI 설치
echo "🔹 AWS CLI 설치 중..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
echo "✅ AWS CLI 버전 확인: $(aws --version)"

# 🔹 Terraform 설치
echo "🔹 Terraform 설치 중..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
echo "✅ Terraform 버전 확인: $(terraform -version)"

# [9] AWS CLI 설정 (자동화)
echo "🔑  AWS CLI 설정 중..."
mkdir -p ~/.aws
cat <<EOF > ~/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

cat <<EOF > ~/.aws/config
[default]
region = ${AWS_DEFAULT_REGION}
output = json
EOF

# # 🔹 AWS 인증 설정
# echo "🔹 AWS 인증을 설정하세요."
# aws configure

# 🔹 AWS STS (보안 토큰 서비스) 테스트
echo "🔹 AWS STS 호출 (현재 IAM 정보 확인)"
aws sts get-caller-identity || { echo "❌ AWS 인증 실패!"; exit 1; }

# 🔹 Terraform 작업 디렉토리로 이동
cd
cd Aira_V3_Terraform/eks

# 🔹 terraform.tfvars 파일 생성 (없는 경우)
if [ ! -f "terraform.tfvars" ]; then
    echo "🔹 terraform.tfvars 파일 생성 중..."

    cat <<EOF > terraform.tfvars
aws_region        = "ap-northeast-2"
vpc_id           = "vpc-0987d9bb0b8efb784"
public_subnet_id_1 = "subnet-005b9f963c1ff689d"
public_subnet_id_2 = "subnet-056c80d61087ecb10"
private_subnet_ids = ["subnet-00fc52b5189371e70", "subnet-06b4603cb89a30b1f"]
eks_cluster_role_arn = "arn:aws:iam::730335258114:role/AmazonEKSAutoClusterRole"
eks_node_role_arn = "arn:aws:iam::730335258114:role/Aira-Node-IAM"
ec2_ssh_key = "Aira-Key"
cluster_name = "Aira-cluster"
EOF
    echo "✅ terraform.tfvars 파일이 생성되었습니다."
fi

# 🔹 Terraform 초기화 및 인프라 구축
echo "🔹 Terraform 초기화 중..."
terraform init

echo "🔹 Terraform 계획 확인 중..."
terraform plan

echo "🔹 인프라 구축 시작..."
terraform apply -auto-approve

echo "✅ 모든 작업이 완료되었습니다!"
