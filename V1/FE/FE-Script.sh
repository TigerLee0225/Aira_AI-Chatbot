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

# 기존 서버 프로세스 종료
pkill -f "python3 -m http.server 8000" || true

# 시스템 업데이트 및 필수 패키지 설치 (비대화형 모드)
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 git wget

# 타임존 설정 및 확인
sudo timedatectl set-timezone Asia/Seoul
echo "Timezone set to: $(timedatectl | grep 'Time zone')"

# 디렉토리 관련 프로세스 종료
if lsof +D /home/ubuntu/Aria_ChatBot > /dev/null; then
    echo "Forcefully killing processes using the directory..."
    fuser -k -9 /home/ubuntu/Aria_ChatBot
fi

# 기존 디렉토리 삭제
if [ -d "/home/ubuntu/Aria_ChatBot" ]; then
    echo "Removing existing Aria_ChatBot directory..."
    rm -rf /home/ubuntu/Aria_ChatBot
fi

# GitHub 리포지토리 클론
cd /home/ubuntu
GITHUB_TOKEN="put your own token"
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GitHub token not found. Exiting."
    exit 1
fi

git clone https://$GITHUB_TOKEN@github.com/ktb-goorm-jaksim3/Aria_ChatBot.git
if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Exiting."
    exit 1
fi

# 브랜치 변경
cd /home/ubuntu/Aria_ChatBot || { echo "Repository not found. Exiting."; exit 1; }
git fetch origin
if git branch -a | grep "main"; then
    git checkout main || { echo "Branch switch failed. Exiting."; exit 1; }
else
    echo "Branch main does not exist. Exiting."
    exit 1
fi

# FE 디렉토리로 이동
cd /home/ubuntu/Aria_ChatBot/FE/src || { echo "FE directory not found. Exiting."; exit 1; }

# 백그라운드 HTTP 서버 실행
if [ -f "server.log" ]; then
    mv server.log server.log.bak.$(date +%Y%m%d%H%M%S)
fi
nohup python3 -m http.server 8000 > server.log 2>&1 &
echo "HTTP server started on port 8000."