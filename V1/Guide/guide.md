echo '======== [1-1] 패키지 업데이트 ========'
sudo apt-get update -y && sudo apt-get upgrade -y

echo '======== [1-2] 타임존 설정 ========'
sudo timedatectl set-timezone Asia/Seoul

echo '======== [1-3] Git 설치 ========'
sudo apt install git-all


echo '======== [2-1] Docker 설치 ========'
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo '======== [2-2] Docker 설치 ========'
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo '======== [2-3] Docker Compose 설치 ========'
sudo apt-get update
sudo apt-get install docker-compose-plugin


## conda 설치
mkdir -p ~/miniconda3
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

## conda로 가상환경 구성
source ~/miniconda3/bin/activate
conda init --all

conda create -n [vm_name] python=[버전 명시]
conda activate vm_name

## Fast api 설치
pip install fastapi==0.111.1

## VSCODE 사용시
Cmd + Shift + P 후 python interpreter 를 통해 생성한 venv로 인터프리터 생성

## default 로 주기

---

## fastapi 구동해보기
uvicorn main:app --port=8081 --reload
>main: 파일 이름
>app: fastapi 인스턴스 이름
>--reload: 소스 변경 사항이 자동 반영되는 옵션