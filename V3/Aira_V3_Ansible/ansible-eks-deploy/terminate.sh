#!/bin/bash
# terminate.sh: deploy.sh로 생성한 모든 Kubernetes 리소스와, 연결된 AWS Load Balancer(ELB)를 삭제하는 스크립트
# 실행 전 "chmod +x terminate.sh"로 실행 권한 부여하세요.
# 주의: 이 스크립트는 지정한 네임스페이스 및 해당 네임스페이스 내의 모든 리소스를 삭제합니다.
# 또한, AWS CLI가 설치되어 있고, AWS 자격 증명이 올바르게 설정되어 있어야 합니다.

set -e

echo "====================================="
echo "Terminating deployed Kubernetes resources..."
echo "====================================="

# 삭제할 네임스페이스 목록 (deploy.sh에서 생성한 네임스페이스)
NAMESPACES=("argocd" "database" "monitoring" "infrastructure")

for ns in "${NAMESPACES[@]}"; do
  if kubectl get namespace "$ns" &> /dev/null; then
    echo "Deleting namespace: $ns"
    kubectl delete namespace "$ns"
  else
    echo "Namespace '$ns' not found. Skipping."
  fi
done

echo "Waiting for namespaces to fully terminate..."
sleep 30

echo "====================================="
echo "Verifying remaining namespaces:"
kubectl get namespaces
echo "====================================="

echo "====================================="
echo "Deleting AWS Load Balancer for argocd-server..."
echo "====================================="

# argocd-server 서비스는 argocd 네임스페이스에 존재하므로, 먼저 LB hostname을 조회합니다.
LB_HOSTNAME=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$LB_HOSTNAME" ]; then
  echo "No Load Balancer hostname found for argocd-server. Skipping LB deletion."
else
  echo "Found Load Balancer hostname: $LB_HOSTNAME"
  # AWS CLI를 사용하여 해당 DNS와 일치하는 Load Balancer ARN을 조회합니다.
  LB_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?DNSName=='${LB_HOSTNAME}'].LoadBalancerArn" --output text)
  if [ -n "$LB_ARN" ]; then
    echo "Deleting load balancer: $LB_ARN"
    aws elbv2 delete-load-balancer --load-balancer-arn "$LB_ARN"
  else
    echo "No matching Load Balancer ARN found for hostname $LB_HOSTNAME"
  fi
fi

echo "====================================="
echo "Termination complete!"
echo "====================================="
