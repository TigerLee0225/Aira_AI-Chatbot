#클러스터 연결
aws eks --region ap-northeast-2 update-kubeconfig --name my-cluster
# 네임스페이스 생성
ansible-playbook -i inventory.ini roles/eks_namespace/tasks/main.yml
# PVC 
ansible-playbook -i inventory.ini roles/eks_pvc/tasks/main.yml
#service
ansible-playbook -i inventory.ini roles/eks_service/tasks/main.yml
#argocd
ansible-playbook -i inventory.ini roles/eks_argocd/tasks/main.yml
#Daemonset
ansible-playbook -i inventory.ini roles/eks_daemonset/tasks/main.yml
#Deployment
ansible-playbook -i inventory.ini roles/eks_deployment/tasks/main.yml
#Statefulset
ansible-playbook -i inventory.ini roles/eks_deployment/tasks/main.yml --extra-vars "deployment_name=mysql"

