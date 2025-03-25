# Aira_V2_GPT
💡 요구사항 정리
	1.	현재 배포 상태
	•	프론트엔드(Frontend)와 백엔드(Backend) 서버를 각각 ECS (Elastic Container Service) 로 배포.
	•	각각의 서비스는 로드 밸런서(ALB) 를 통해 관리됨.
	•	데이터베이스는 MySQL 컨테이너 로 백엔드 내부에서 운영.
	2.	문제점
	•	OpenAI API 호출을 통해 대화가 이루어지는데, 현재는 백엔드가 프라이빗 네트워크 안에 있음.
	•	OpenAI API는 외부 서비스이므로, 프라이빗 네트워크에서는 호출할 수 없음 → 응답을 받지 못함.
	3.	해결책
	•	OpenAI API 호출을 담당하는 GPT Generate Endpoint 를 퍼블릭 네트워크로 이동.
	•	동시에 FIFO SQS (Simple Queue Service) 를 도입하여 트랜잭션 무결성을 보장.
	•	즉, OpenAI API 호출을 담당하는 별도의 컨테이너를 퍼블릭에 배치하여 호출 가능하게 하고, 이 호출이 SQS와 함께 관리되도록 개선.

📌 새로운 아키텍처의 주요 변경 사항
	•	백엔드 내부의 GPT 호출 로직을 분리하여 퍼블릭 환경에서 실행되는 GPT 컨테이너 로 이동.
	•	FIFO SQS 를 도입하여 트랜잭션 무결성을 확보.
	•	OpenAI API를 호출하는 부분은 퍼블릭 네트워크에 배치하여 접근 가능하도록 설정.


🎯 왜 GPT Worker가 필요한가?
	1.	SQS에서 메시지를 가져와 OpenAI API를 호출하는 역할을 담당.
	2.	비동기 작업을 수행하여 병렬 처리 가능.
	3.	트랜잭션 무결성을 유지하면서 OpenAI API 호출을 관리.
	4.	백엔드가 직접 OpenAI API를 호출하지 않고, Worker가 대신 API 호출을 처리하여 분산 처리 가능.


 🎯 최적화된 GPT 호출 흐름 (Worker 추가)

1️⃣ 백엔드에서 SQS 큐에 메시지 저장
	•	사용자가 질문을 하면, 백엔드는 FIFO SQS에 메시지를 저장.

2️⃣ GPT Worker가 SQS에서 메시지를 가져옴
	•	SQS의 메시지를 읽고 OpenAI API를 호출.

3️⃣ OpenAI API 호출 후 응답 수신
	•	GPT Worker가 OpenAI API에서 응답을 받아 SQS에 다시 저장.

4️⃣ 백엔드가 SQS에서 응답을 가져와 사용자에게 전달
	•	백엔드는 SQS에서 결과를 가져와 클라이언트(프론트엔드)로 전달.


📌 새로운 GPT Worker 기반 아키텍처
	1.	백엔드(BE)는 SQS에 요청을 보내고, 즉시 “처리 중입니다.”라는 응답을 반환.
	2.	GPT Worker(gpt-worker)는 SQS에서 메시지를 읽어 OpenAI API를 호출한 후 결과를 다시 SQS에 저장.
	3.	클라이언트는 GET /result/{request_id} API를 호출하여 결과를 가져옴


🚀 최종 구현 흐름

1️⃣ 백엔드 API (POST /generate/)
	•	클라이언트가 질문을 보내면 SQS에 저장 후 request_id를 반환.

2️⃣ GPT Worker (gpt-worker)
	•	SQS에서 메시지를 가져와 OpenAI API 호출 후 결과를 다시 SQS에 저장.

3️⃣ 백엔드 API (GET /result/{request_id})
	•	클라이언트가 request_id를 이용하여 결과를 조회

🎯 이 설계의 장점

✅ 비동기 처리로 빠른 응답 가능
✅ 트랜잭션 무결성 보장 (FIFO SQS 사용)
✅ GPT Worker를 병렬로 실행하면 OpenAI API 호출을 더 빠르게 처리 가능
✅ 백엔드가 직접 OpenAI API를 호출하지 않으므로 로드 감소
