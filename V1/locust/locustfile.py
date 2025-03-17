import random
from locust import HttpUser, task, between

class UserBehavior(HttpUser):
    wait_time = between(1, 3)  # 사용자 간 대기 시간

    @task
    def load_page(self):
        self.client.get("/")  # 메인 페이지 로드

    @task
    def send_message(self):
        #
        #
        # self.client.post("/generate/", json={"prompt": "Hello, ChatGPT!", "max_tokens": 200, "temperature": 0.7)
        pass # 주석 처리된 부분 대신 아무 작업도 수행하지 않음. 백엔드 api 호출량 고려하여 임시 주석처리
    @task
    def health_check(self):
        if random.random() < 0.33:
            self.client.get("/health")  # 헬스 체크 요청

    @task
    def load_heavy(self):
        self.client.get("/load")  # CPU 부하 요청