# 프로메테우스 다운로드
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
# 압축 해제 
tar xvfz prometheus-2.45.0.linux-amd64.tar.gz

# 프로메테우스 파일 복사 
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

sudo cp -r prometheus.yml /etc/prometheus
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable promethues
sudo systemctl status prometheus