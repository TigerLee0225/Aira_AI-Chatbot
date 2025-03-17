import random
import time
from locust import HttpUser, task, between

class VueFrontendLoadTest(HttpUser):
    """ Vue.js 프론트엔드 및 트랜잭션 장애 탐지를 포함한 부하 테스트 """
    wait_time = between(1, 3)  # 요청 간 대기 시간 (1~3초)

    @task(5)
    def visit_login(self):
        """ 로그인 페이지 방문 """
        response = self.client.get("/login")
        self.check_response(response, "로그인 페이지")

    @task(5)
    def visit_signup(self):
        """ 회원가입 페이지 방문 """
        response = self.client.get("/signup")
        self.check_response(response, "회원가입 페이지")

    @task(3)
    def visit_intro(self):
        """ 소개 페이지 방문 """
        response = self.client.get("/intro")
        self.check_response(response, "소개 페이지")

    @task(4)
    def visit_question(self):
        """ 질문 목록 페이지 방문 """
        response = self.client.get("/question")
        self.check_response(response, "질문 페이지")

    @task(3)
    def visit_summary(self):
        """ 요약 페이지 방문 """
        response = self.client.get("/summary")
        self.check_response(response, "요약 페이지")

    @task(6)
    def visit_chat(self):
        """ 챗봇 페이지 방문 """
        response = self.client.get("/chat")
        self.check_response(response, "챗봇 페이지")

    @task(2)
    def health_check(self):
        """ 헬스 체크 API 호출 """
        response = self.client.get("/health")
        self.check_response(response, "헬스 체크")

    @task(3)
    def monitor_http_requests(self):
        """ 초당 HTTP 요청 수 모니터링 """
        response = self.client.get("/metrics/nginx_http_requests_total")
        self.check_response(response, "HTTP 요청 수 모니터링")

    @task(3)
    def monitor_http_500_errors(self):
        """ HTTP 500 에러 수 모니터링 """
        response = self.client.get("/metrics/nginx_http_responses_total?code=500")
        self.check_response(response, "HTTP 500 에러 모니터링")

    @task(2)
    def monitor_active_connections(self):
        """ 활성화된 연결 수 모니터링 """
        response = self.client.get("/metrics/nginx_connections_active")
        self.check_response(response, "활성 연결 모니터링")

    @task(2)
    def monitor_waiting_connections(self):
        """ 대기 중인 연결 수 모니터링 """
        response = self.client.get("/metrics/nginx_connections_waiting")
        self.check_response(response, "대기 중인 연결 모니터링")

    @task(2)
    def monitor_request_latency(self):
        """ 요청 처리 시간 모니터링 """
        response = self.client.get("/metrics/nginx_http_requests_duration_seconds")
        self.check_response(response, "요청 처리 시간 모니터링")

    def check_response(self, response, endpoint):
        """ 응답 코드 확인 및 로그 출력 """
        if response.status_code >= 500:
            print(f"❌ {endpoint} 요청 실패 (서버 오류): {response.status_code}")
        elif response.status_code >= 400:
            print(f"⚠️ {endpoint} 요청 실패 (클라이언트 오류): {response.status_code}")
        else:
            print(f"✅ {endpoint} 요청 성공: {response.status_code}")