from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

# 환경 변수 로드
load_dotenv()

# DATABASE_URL에서 데이터베이스 이름 추출
DB_URL = os.getenv("DATABASE_URL")
DB_NAME = DB_URL.split('/')[-1]
ROOT_URL = '/'.join(DB_URL.split('/')[:-1])

def create_database():
    # 데이터베이스 생성을 위한 root 엔진
    root_engine = create_engine(ROOT_URL)
    
    # 데이터베이스 존재 여부 확인 및 생성
    with root_engine.connect() as conn:
        conn.execute(text("COMMIT"))  # Reset any open transaction
        databases = conn.execute(text("SHOW DATABASES"))
        if DB_NAME not in [d[0] for d in databases]:
            conn.execute(text(f"CREATE DATABASE {DB_NAME}"))
            print(f"Database {DB_NAME} created successfully!")
        else:
            print(f"Database {DB_NAME} already exists!")

# MySQL 엔진 설정
engine = create_engine(
    DB_URL,
    pool_size=5,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=1800
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 종속성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 데이터베이스 초기화 함수
def init_db():
    create_database()
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully!")
