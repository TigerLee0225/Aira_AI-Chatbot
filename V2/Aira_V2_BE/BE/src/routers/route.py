import os
from fastapi import APIRouter, Depends, FastAPI, Request, HTTPException
from sqlalchemy.orm import Session
from service.chat import generate_text
from service.health import health_check_service
from service.load import load_heavy_service
from service.auth import read_users_me, register, login
from service.answer import save_answers
from db.database import get_db
from schemas import user_schema
from models.chat import ChatRequest, ChatResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from schemas.answer_schema import AnswerCreate, AnswerResponse
from dotenv import load_dotenv
from models.user import User  # User 모델 임포트 추가
import requests

# .env 파일 로드
load_dotenv()

# 환경 변수에서 SECRET_KEY 및 ALGORITHM 가져오기
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

app = FastAPI()

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

@router.post("/generate/", response_model=ChatResponse)
async def generate_endpoint(chat_request: ChatRequest):
    try:
        # GPT Worker로 요청을 전달
        response = await generate_text(chat_request)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"GPT Worker 호출 실패: {str(e)}")


@router.post("/auth/register", response_model=user_schema.UserResponse)
async def register_route(user: user_schema.UserCreate, db: Session = Depends(get_db)):
    return register(user, db)

@router.post("/auth/login", response_model=user_schema.Token)
async def login_route(request: Request, user: user_schema.UserLogin, db: Session = Depends(get_db)):
    # 요청 바디 전체를 로깅
    body = await request.body()
    return login(user, db)

@router.get("/health")
async def health_check_route():
    return health_check_service()

@router.get("/load")
async def load_heavy_route():
    return load_heavy_service()

@router.get("/auth/me", response_model=user_schema.UserResponse)
async def read_user_me_route(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError as e:
        print(f"JWT Error: {str(e)}")  # 오류 로그 추가
        raise credentials_exception
        
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception
        
    return user

@router.post("/questions/submit", response_model=AnswerResponse)
async def submit_answers(answer: AnswerCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user = read_users_me(token, db)  # 사용자 정보 가져오기
    if user is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")  # 사용자 정보가 없을 경우
    return save_answers(answer, db, user.id)  # 사용자 ID를 사용하여 답변 저장

@router.get("/result/{request_id}")
async def get_result(request_id: str):
    response = sqs.receive_message(
        QueueUrl=RESPONSE_QUEUE_URL,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=5
    )

    if "Messages" in response:
        for message in response["Messages"]:
            body = json.loads(message["Body"])

            if body["request_id"] == request_id:
                result = body["result"]

                # 처리된 메시지는 삭제
                sqs.delete_message(
                    QueueUrl=RESPONSE_QUEUE_URL,
                    ReceiptHandle=message["ReceiptHandle"]
                )

                return {"status": "completed", "result": result}

    return {"status": "processing", "message": "Request is still being processed"}

# 라우터 등록
app.include_router(router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 또는 특정 도메인 리스트
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)