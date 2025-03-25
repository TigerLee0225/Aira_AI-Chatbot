#!/bin/bash
# 로컬에서 이거 먼저 실행
# scp -i ~/Downloads/Aira-Key.pem ~/Downloads/Aira-Key.pem ubuntu@3.35.36.173:~/.ssh/

set -e  # 오류 발생 시 스크립트 중단

# ==========================
# 0. AWS 환경 설정
# ==========================
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_DEFAULT_REGION="ap-northeast-2"
IAM_PROFILE_NAME="Aira-Node-IAM"
EKS_CLUSTER_NAME="Aira-cluster"

# 깃 클론
# git clone https://github.com/ktb-goorm-jaksim3/Aira_V3_Ansible.git

echo "====================================="
echo "📌 AWS 및 시스템 기본 설정"
echo "====================================="
export AWS_REGION="$AWS_DEFAULT_REGION"

# ==========================
# 1. 시스템 패키지 업데이트 및 필수 패키지 설치
# ==========================
echo "🛠️  시스템 패키지 업데이트 중..."
sudo apt-get update -y
sudo apt-get install -y software-properties-common curl unzip python3 python3-pip python3.12-venv

# ==========================
# 2. Python 가상환경(ansible-env) 생성 및 활성화
# ==========================
VENV_DIR="/home/ubuntu/Aira_V3_Ansible/ansible-env"

if [ ! -d "$VENV_DIR" ]; then
    echo "🔧  ansible-env 가상환경 생성 중..."
    python3 -m venv "$VENV_DIR"
fi

# 가상환경 활성화
source "$VENV_DIR/bin/activate"

# VIRTUAL_ENV 확인
if [ -z "$VIRTUAL_ENV" ]; then
  echo "❌ ERROR: 가상환경 활성화 실패."
  exit 1
fi

export ANSIBLE_PYTHON_INTERPRETER="${VENV_DIR}/bin/python3"
echo "✅ VIRTUAL_ENV: $VIRTUAL_ENV"
echo "✅ ANSIBLE_PYTHON_INTERPRETER: $ANSIBLE_PYTHON_INTERPRETER"

# ==========================
# 3. 가상환경 내 Ansible 및 AWS SDK 설치
# ==========================
echo "📦  Ansible 및 AWS 관련 패키지 설치 중..."
pip install --upgrade pip
pip install ansible boto3 botocore kubernetes

# Ansible 및 boto3 버전 확인
ansible --version
python -c "import boto3; print('boto3:', boto3.__version__)"
python -c "import botocore; print('botocore:', botocore.__version__)"

# ==========================
# 4. Ansible 인벤토리 파일 설정
# ==========================
echo "📄  Ansible 인벤토리 파일 생성 중..."
cat <<EOF > ~/Aira_V3_Ansible/hosts
[eks]
$(curl -s http://169.254.169.254/latest/meta-data/instance-id) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/Aira-Key.pem
EOF

echo "📑  Ansible 인벤토리 파일 내용:"
cat ~/Aira_V3_Ansible/hosts

# ==========================
# 5. AWS CLI 설치 및 구성
# ==========================
echo "☁️  AWS CLI 설치 중..."
sudo apt remove awscli -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

echo "🔍  AWS CLI 버전 확인"
aws --version

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

echo "🔍  AWS 인증 확인 (STS 호출)"
aws sts get-caller-identity

# ==========================
# 6. IAM Instance Profile 설정
# ==========================
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ 인스턴스 ID를 가져올 수 없습니다. 스크립트를 종료합니다."
    exit 1
fi
echo "✅ 현재 인스턴스 ID: $INSTANCE_ID"

# 기존 IAM Profile 해제
CURRENT_PROFILE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].IamInstanceProfile.Arn' --output text)

if [[ "$CURRENT_PROFILE" != "None" && -n "$CURRENT_PROFILE" ]]; then
    ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations \
        --filters Name=instance-id,Values="$INSTANCE_ID" \
        --query 'IamInstanceProfileAssociations[*].AssociationId' --output text)

    if [[ -n "$ASSOCIATION_ID" ]]; then
        aws ec2 disassociate-iam-instance-profile --association-id "$ASSOCIATION_ID"
        echo "✅ 기존 IAM Instance Profile 해제 완료."
    fi
fi

# 새로운 IAM Profile 연결
echo "🔄 새로운 IAM Instance Profile 연결 중..."
aws ec2 associate-iam-instance-profile --instance-id "$INSTANCE_ID" \
    --iam-instance-profile Name="$IAM_PROFILE_NAME"
echo "✅ IAM Instance Profile 연결 완료."

# ==========================
# 7. IMDS 설정 변경
# ==========================
echo "🔄 IMDS 설정을 변경하여 HttpTokens를 'optional'로 설정 중..."
aws ec2 modify-instance-metadata-options --instance-id "$INSTANCE_ID" \
    --http-tokens optional --http-endpoint enabled
echo "✅ IMDS 설정 변경 완료."

# ==========================
# 8. EKS 클러스터 연결 및 설정
# ==========================
echo "🔄 EKS 클러스터 연결 중..."
aws eks --region "$AWS_DEFAULT_REGION" update-kubeconfig --name "$EKS_CLUSTER_NAME"

# eksctl 설치 확인 및 설치
if ! command -v eksctl &> /dev/null; then
    echo "eksctl not found. Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installed."
fi

# OIDC Provider 연결
eksctl utils associate-iam-oidc-provider --region "$AWS_DEFAULT_REGION" --cluster "$EKS_CLUSTER_NAME" --approve

# ==========================
# 9. kubectl 및 Helm 설치
# ==========================
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Helm 설치
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=true \
  --set controller.serviceAccount.name=ebs-csi-controller-sa

echo "🚀 모든 설정이 완료되었습니다!"
