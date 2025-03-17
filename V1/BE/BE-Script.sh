#!/bin/bash

# CodeDeploy 설치 (비대화형 모드)
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install ruby-full -y
sudo DEBIAN_FRONTEND=noninteractive apt install wget -y
cd /home/ubuntu
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
systemctl status codedeploy-agent
systemctl start codedeploy-agent

# 기존 FastAPI 프로세스 종료
pkill -f "uvicorn main:app" || true

# 시스템 업데이트 및 필수 패키지 설치 (비대화형 모드)
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 git wget

# 타임존 설정
sudo timedatectl set-timezone Asia/Seoul

# Miniconda 설치
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# 현재 활성화된 conda 환경 비활성화
conda deactivate

# Conda 경로 로드 및 초기화
source ~/miniconda3/bin/activate
conda init --all

# 기존 fastapi 환경이 있다면 제거
conda env remove -n fastapi -y

# Conda 가상환경 생성 및 활성화
conda create -n fastapi python=3.9 -y
conda activate fastapi

# 필수 라이브러리 설치 (가상환경 내)
pip install fastapi==0.111.1 uvicorn python-dotenv

# Kill any processes using the directory
if lsof +D /home/ubuntu/Aria_ChatBot; then
    echo "Forcefully killing processes using the directory..."
    fuser -k -9 /home/ubuntu/Aria_ChatBot
fi

# Check if the directory exists and remove it
if [ -d "/home/ubuntu/Aria_ChatBot" ]; then
    echo "Removing existing Aria_ChatBot directory..."
    rm -rf /home/ubuntu/Aria_ChatBot
fi

# GitHub 리포지토리 클론
cd /home/ubuntu
GITHUB_TOKEN="put your own token"
git clone https://$GITHUB_TOKEN@github.com/ktb-goorm-jaksim3/Aria_ChatBot.git || { echo "리포지토리 클론 실패. 종료"; exit 1; }
cd /home/ubuntu/Aria_ChatBot || { echo "디렉토리 이동 실패. 종료"; exit 1; }
git checkout main || { echo "브랜치 전환 실패. 종료"; exit 1; }

# BE 디렉토리로 이동
cd /home/ubuntu/Aria_ChatBot/BE/src || { echo "BE 디렉토리 없음. 종료"; exit 1; }

# .env 파일 생성
cat <<EOF > .env
OPENAI_API_KEY=""
EOF

# Python 의존성 설치
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt 파일이 없습니다. 종료합니다."
    exit 1
fi

# FastAPI 서버 백그라운드 실행
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > uvicorn.log 2>&1 &