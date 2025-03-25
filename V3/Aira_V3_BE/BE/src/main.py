from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from routers.route import router
from db.database import init_db
import os

# 환경변수 로드
load_dotenv(os.getenv("ENV_FILE"))

# Database 초기화
init_db()

# FastAPI 인스턴스 생성
app = FastAPI()

# CORS 설정 수정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Vue.js 개발 서버 주소
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global middleware to ensure every response gets CORS headers—even error responses.
@app.middleware("http")
async def add_cors_header(request: Request, call_next):
    try:
        response = await call_next(request)
    except Exception as exc:
        # If an exception is raised and not handled, create a JSON response for it.
        response = JSONResponse(content={"detail": str(exc)}, status_code=500)
    # Ensure the CORS header is set
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response

# Custom exception handler for HTTPException (optional, as the middleware above covers most cases)
#@app.exception_handler(HTTPException)
#async def http_exception_handler(request: Request, exc: HTTPException):
#    return JSONResponse(
#        status_code=exc.status_code,
#        content={"detail": exc.detail},
#        headers={"Access-Control-Allow-Origin": "*"}
#    )

# Include your router (which includes your /generate/ endpoint)
app.include_router(router)

# 기본 엔드포인트 확인용
@app.get("/")
async def root():
    return {"message": "API 서버 실행 중"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level="debug")