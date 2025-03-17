echo '======== [3-1] conda 설치 ========'
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

echo '======== [3-2] conda로 가상환경 구성 ========'
source ~/miniconda3/bin/activate
conda init --all

conda create -y -n locust python=3.9
conda activate locust

echo '======== [4-1] locust 설치 ========'
pip3 install locust