#!/bin/bash
echo '======== [1-1] 패키지 업데이트 ========'
sudo apt-get update -y && sudo apt-get upgrade -y

echo '======== [1-2] 타임존 설정 ========'
sudo timedatectl set-timezone Asia/Seoul

echo '======== [1-3] Git 설치 ========'
sudo apt install git-all


echo '======== [2-1] Docker 설치 ========'
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


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


echo '======== [3-1] conda 설치 ========'
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

echo '======== [3-2] conda로 가상환경 구성 ========'
cd ../../
source ~/miniconda3/bin/activate
conda init --all

conda create -y -n fastapi python=3.9
conda activate fastapi

echo '======== [3-2] Fastapi 설치 ========'
pip install fastapi==0.111.1