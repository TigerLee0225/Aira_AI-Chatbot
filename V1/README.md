# 💠 **Aira - 클라우드 퍼포먼스 최적화 프로젝트** 💠

## **💠 프로젝트 개요**

### **프로젝트 소개**
Aira는 클라우드 퍼포먼스 최적화를 목표로 개인화된 AI 챗봇 서비스를 제공합니다. 트래픽 부하 분산, 자동 리소스 관리, 실시간 성능 모니터링을 통해 고가용성과 효율성을 극대화하는 클라우드 환경에서 운영됩니다.

### **프로젝트 목표**
1. 개발 및 운영 환경에서의 Load Balancing 및 Scaling 테스트 실행  
2. 실시간 모니터링 시스템과 경보 설정을 통한 운영 효율성 향상  
3. 클라우드 환경에서의 성능 저하 문제 분석 및 최적화 방안 연구  
 
---

### **지원 기능**
- 사용자 성향에 맞춤형 대화 서비스  
- 트래픽 변화에 따른 서버 증감 및 자동 복구  
- 시스템 리소스 상태 및 장애 발생 시 경고  

---

## **💠 역할 분담**

![image](https://github.com/user-attachments/assets/3075c3de-a2ea-4b79-9075-279c481142d1)

### **이영범 (팀장)**
- 이메일: yblee94@outlook.com  
- 역할:  
  - 프로젝트 총괄 관리, 일정 및 태스크 관리  
  - 프로젝트 기획 및 아이템 선정 주도  
  - 아키텍처 구축 리드  

### **오재근 (부팀장)**
- 이메일: worms773789@gmail.com  
- 역할:  
  - Backend 개발 리드  

### **김상아**
- 이메일: cometokr1@naver.com  
- 역할:  
  - 모니터링 구축 리드  
  - FrontEnd 개발 리드  

---
## **🗓️ 프로젝트 기간**

| 구분 | 기간 | 활동 |
|-------|-------|-------|
| 아이템 선정 및 프로젝트 기획 | 24.12.06 - 24.12.13 | - 프로젝트 기획 및 주제 선정<br>- 기획안 작성|
| 인프라 아키텍처 구축 | 24.12.16 - 24.12.20 | - EC2 인스턴스로 FE/BE 서버 구축<br>- MySQL DB 클러스터 및 인스턴스 구축<br>- Redis 엔진 활용 및 NoSQL DB 구축<br>- 스토리지 구축 |
| 기능1 구현 | 24.12.16 - 25.01.08 | - 엔드 유저 대상 질문 및 응답 저장 기능 구현 |
| 기능 2,3 구현 | 24.12.19 - 25.01.08 | - 설문 종료 후 사용자의 챗봇 유형 출력<br>- 웹 페이지 구현 |
| 모니터링 구축 | 24.12.10 - 25.01.08 | - 실시간 모니터링 서비스 구축<br>- EC2 인스턴스를 활용하여 CloudWatch와 Prometheus 구축 |
| 모니터링 시각화 | 25.01.06 - 25.01.10 | - EC2 인스턴스로 Grafana 대시보드 구축<br>- CloudWatch로 EC2 인스턴스 활용 경보 설정 및 Grafana 대시보드 구축 |
| 로드 부하 테스트 실행 | 25.01.09 - 25.01.13 | - EC2 인스턴스로 Locust 구축<br>- Locust로 테스트 시나리오 실행 |
| 클라우드 퍼포먼스 최적화 | 25.01.09 - 25.01.13 | - 성능 저하 문제점 분석 및 해결방안 도출<br>- Grafana 대시보드를 통한 성능 저하 병목현상 분석<br>- 리소스 병목현상에 적절한 솔루션 적용 |
| 최종 보고 | 25.01.13 - 25.01.15 | -완료 보고 PPT 제작 및 발표 준비 |


---

## **💠 사용 스택**

![24 12 12_jaksim_skillset_V4](https://github.com/user-attachments/assets/1af3704b-1b2f-4b66-a695-71eb070ecf1f)

### **Backend**
- FastAPI, Python, Uvicorn, OpenAI API  

### **Frontend**
- HTML, CSS, JavaScript, Bootstrap  

### **Database**
- Amazon Aurora (MySQL 호환), Redis (Elasticache)  

### **Infra**
- AWS EC2, VPC, AutoScaling, Ubuntu, Docker  

### **Monitoring & Test**
- CloudWatch, Prometheus, Grafana, Locust  

### **Storage**
- Amazon EFS, S3  

### **CI/CD**
- GitHub Actions  

### **Tools**
- Git, GitHub, Vscode, Discord, Notion, Clickup, Dockerhub  

---

## **🛠️ Service Architecture**

![image](https://github.com/user-attachments/assets/2159b988-6ec5-40ba-b318-249c219a58b3)

1. 엔드 유저의 Aira Web URL 접속
2. ELB(Elastic Load Balancer)를 통해 현재 트래픽 부하가 발생하지 않은 FE Server로 연결
3. 엔드 유저가 연결된 웹 서버는 정적 웹사이트 페이지를 S3 Bucket에서 불러와 엔드 유저에게 서비스
<br> 3.1 정적 콘텐츠는 S3 버킷 스토리지에 저장됨
4. FE Server를 타겟 그룹으로 생성된 Auto Scaling 그룹은 발생하는 트래픽 요청에 따라 자동으로 서버를 줄이거나 확장
5. 엔드 유저에게 서비스하는 동적 어플리케이션을 수행하기 위해 Elastic Load Balancer가 트래픽 부하가 발생하지 않은 BE Server로 연결
6. BE Server에서 서비스하는 어플리케이션을 엔드 유저는 수행
<br> 6.1 어플리케이션 Data는 EFS(Elastic File System)을 통해 BE Server 간에 동기화
7. BE Server를 타겟 그룹으로 생성된 Auto Scaling 그룹은 발생하는 트래픽 요청에 따라 자동으로 서버를 줄이거나 확장
8. 어플리케이션을 통해 수집된 고객 응답 데이터는 Aurora(MySQL호환) 데이터베이스에 저장, 엔드 유저의 세션 데이터는 Redis 엔진을 사용하는 Elasticache에 저장
9. 데이터베이스는 Multi-AZ 기능을 활용해 설정한 여러 가용영역에 복제하여 재해 상황 대비
10. CloudWatch 및 Prometheus를 활용하여 App 가동 중 발생하는 로그 데이터 및 운영 상황 모니터링 및 수집
11. Grafana를 활용해 데이터 시각화

---

## 설치

Create and activate a <a href="https://fastapi.tiangolo.com/virtual-environments/" class="external-link" target="_blank">가상 환경</a> 셋팅 이후 FASTAPI 설치:

<div class="termy">

```console
$ pip install "fastapi[standard]"

---> 100%
```

</div>

---

### 실행

서버 실행하기:

<div class="termy">

```console
$ fastapi dev main.py

 ╭────────── FastAPI CLI - Development mode ───────────╮
 │                                                     │
 │  Serving at: http://127.0.0.1:8000                  │
 │                                                     │
 │  API docs: http://127.0.0.1:8000/docs               │
 │                                                     │
 │  Running in development mode, for production use:   │
 │                                                     │
 │  fastapi run                                        │
 │                                                     │
 ╰─────────────────────────────────────────────────────╯

INFO:     Will watch for changes in these directories: ['/home/user/code/awesomeapp']
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [2248755] using WatchFiles
INFO:     Started server process [2248757]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

</div>

---

