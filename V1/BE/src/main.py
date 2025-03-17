from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI
import os

# 환경변수 로드
load_dotenv()

# OpenAI API 클라이언트 초기화
client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),  
)

# FastAPI 인스턴스 생성
app = FastAPI()

# 데이터 모델 정의
class ChatRequest(BaseModel):
    prompt: str
    max_tokens: int = 2000
    temperature: float = 0.7

# 기본 엔드포인트 확인용
@app.get("/", include_in_schema=False)
async def root():
    return {"message": "API 서버 실행 중"}


# OpenAI API 호출 엔드포인트
@app.post("/generate/")
async def generate_text(request: ChatRequest):
    try:
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": request.prompt}
            ],
            max_tokens=request.max_tokens,
            temperature=request.temperature
        )
        return {
            "prompt": request.prompt, 
            "response": response.choices[0].message.content
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


#헬스 체크
@app.get("/health")
async def health_check():
    try:
        # ChatGPT API에 간단한 요청을 보내서 헬스 체크
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "system", "content": "Health check."}],
            max_tokens=5
        )
        return {"status": "healthy", "response": response.choices[0].message.content}
    except Exception as e:
        raise HTTPException(status_code=500, detail="ChatGPT API is not reachable.")

# 로드 부하 테스트
@app.get("/load")
async def load_heavy():
    # CPU 부하를 주기 위한 작업
    total = 0
    for i in range(10**8):  # 큰 수의 반복
        total += i
    return {"status": "completed", "total": total}


# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 (배포 환경에서는 특정 도메인으로 제한 권장)
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용
    allow_headers=["*"],  # 모든 헤더 허용
)