#!/bin/bash
# deploy.sh: EKS 클러스터 및 관련 리소스를 한 번에 배포하는 종합 스크립트
# 실행 전 "chmod +x deploy.sh"로 실행 권한 부여하세요.

set -e  # 오류 발생 시 스크립트 중단

echo "====================================="
echo "0. AWS Region Configuration"
echo "====================================="
export AWS_REGION="ap-northeast-2"

echo "====================================="
echo "1. Activating Ansible Virtual Environment (ansible-env)"
echo "====================================="
# activate_and_update.sh: 가상환경을 활성화하고 inventory.ini 파일의 인터프리터 경로를 동적으로 업데이트

# 가상환경 활성화 (절대경로 사용)
source /home/ubuntu/Aira_V3_Ansible/ansible-env/bin/activate

# VIRTUAL_ENV가 올바르게 설정되었는지 확인
if [ -z "$VIRTUAL_ENV" ]; then
  echo "ERROR: VIRTUAL_ENV is not set. Check your activate script."
  exit 1
fi

# 가상환경의 Python 인터프리터 경로 설정
export ANSIBLE_PYTHON_INTERPRETER="${VIRTUAL_ENV}/bin/python3"

echo "VIRTUAL_ENV is set to: $VIRTUAL_ENV"
echo "ANSIBLE_PYTHON_INTERPRETER is set to: $ANSIBLE_PYTHON_INTERPRETER"
echo "Current PATH: $PATH"
which ansible
which python

# inventory.ini 파일 내의 ansible_python_interpreter 값을 VIRTUAL_ENV에 맞게 업데이트 (예: [localhost] 그룹)
# 여기서는 inventory.ini 파일이 현재 작업 디렉토리에 있다고 가정합니다.
sed -i "s|^\(localhost .*ansible_python_interpreter=\).*|\1${VIRTUAL_ENV}/bin/python3|" inventory.ini

echo "Updated inventory.ini:"
cat inventory.ini

echo "====================================="
echo "2. Connecting to EKS Cluster"
echo "====================================="
# 클러스터 이름(Aira-cluster) 및 리전(ap-northeast-2)은 환경에 맞게 수정하세요.
aws eks --region ap-northeast-2 update-kubeconfig --name Aira-cluster
# eksctl 설치 확인 및 설치 (없을 경우)
if ! command -v eksctl &> /dev/null
then
    echo "eksctl not found. Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl installed."
fi

echo "====================================="
echo "3. Associating IAM OIDC Provider"
echo "====================================="
eksctl utils associate-iam-oidc-provider --region ap-northeast-2 --cluster Aira-cluster --approve


echo "====================================="
echo "3.5 Installing kubernetes & kubectl"
echo "====================================="

# [A] kubectl 설치 확인 및 설치 (없을 경우)
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Installing kubectl..."
    # 최신 안정 버전 kubectl 다운로드
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    # 바이너리를 /usr/local/bin으로 설치
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed."
else
    echo "kubectl is already installed."
fi

# [B] Python kubernetes 패키지 설치 확인 및 설치 (없을 경우)
echo "Checking if Python kubernetes package is installed..."
if ! python3 -c "import kubernetes" 2>/dev/null; then
    echo "Python kubernetes package not found. Installing..."
    pip3 install kubernetes
else
    echo "Python kubernetes package is already installed."
fi

echo "====================================="
echo "4. Creating IAM Service Account for AWS Load Balancer Controller"
echo "====================================="
kubectl delete serviceaccount aws-load-balancer-controller -n kube-system || true
eksctl create iamserviceaccount \
  --cluster Aira-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::730335258114:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

# 확인 후 없으면 수동 생성
if ! kubectl get sa aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
  echo "Service account not found; creating manually..."
  kubectl create serviceaccount aws-load-balancer-controller -n kube-system
fi

#-----------------------------------------------------------------
# 5. Skipping AWS Load Balancer Controller installation via Helm
#     (ALB is managed via Terraform and is already built)
#-----------------------------------------------------------------
echo "====================================="
echo "5. Skipping AWS Load Balancer Controller installation via Helm (managed by Terraform)"
echo "====================================="
# helM 설치
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
#helm 저장소 추가 및 업데이트
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
# EBS CSI 드라이버 설치
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=true \
  --set controller.serviceAccount.name=ebs-csi-controller-sa

  
#-----------------------------------------------------------------
# 6. Skipping waiting for AWS Load Balancer Controller webhook endpoints
#     (not applicable since LB Controller is not being installed)
#-----------------------------------------------------------------
echo "====================================="
echo "6. Skipping webhook endpoints wait (ALB is managed externally)"
echo "====================================="

echo "====================================="
echo "7. Installing Argo CD"
echo "====================================="

# 1. argocd 네임스페이스 생성 (이미 존재하면 무시)
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."

# 2. Argo CD 설치 매니페스트 적용 (공식 stable 버전)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. 기본 네임스페이스를 argocd로 설정 (kubectl config)
kubectl config set-context --current --namespace=argocd

# 4. Argo CD CLI 최신 버전(예: v2.11.0)을 다운로드합니다.
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
# 설치 확인
argocd version --client

# 5. (선택 사항) Argo CD API 서버를 외부에서 접근하기 위해 서비스 타입을 LoadBalancer로 변경
#    이 단계는 Ingress나 Port-forwarding을 사용하지 않을 경우에 필요합니다
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "Argo CD installation complete."

# echo "====================================="
# echo "8. Deploying Kubernetes Resources using Ansible"
# echo "====================================="

# # 1. 네임스페이스 생성
# echo ">> Deploying Namespaces..."
# ansible-playbook -i inventory.ini roles/eks_namespace/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 2. PVC 생성
# echo ">> Deploying Persistent Volume Claims (PVCs)..."
# ansible-playbook -i inventory.ini roles/eks_pvc/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 3. Service 생성
# echo ">> Deploying Services..."
# ansible-playbook -i inventory.ini roles/eks_service/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 4. Ingress 생성
# echo ">> Deploying Ingresses..."
# ansible-playbook -i inventory.ini roles/eks_ingress/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 5. DaemonSet 배포 (예: Node Exporter)
# echo ">> Deploying DaemonSets..."
# ansible-playbook -i inventory.ini roles/eks_daemonset/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 6. Stateless 애플리케이션 (Deployment) 배포
# echo ">> Deploying Deployments..."
# ansible-playbook -i inventory.ini roles/eks_deployment/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 7. Stateful 애플리케이션 (StatefulSets for Grafana, Prometheus, MySQL) 배포
# echo ">> Deploying StatefulSets..."
# ansible-playbook -i inventory.ini roles/eks_statefulset/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# # 8. ArgoCD 구성 (RBAC, ConfigMap, Secret, Deployment, Service, Ingress) // 위에서 이미 배포하므로 불필요
# # echo ">> Deploying ArgoCD Components..."
# # ansible-playbook -i inventory.ini roles/eks_argocd/tasks/main.yml -e "manifest_dir=/home/ubuntu/Aira_V3_Ansible/ansible-eks-deploy/k8s-manifests"

# echo "====================================="
# echo "9. Verifying deployed resources"
# echo "====================================="
# kubectl get all --all-namespaces

# echo "====================================="
# echo "Deployment complete!"
# echo "====================================="
