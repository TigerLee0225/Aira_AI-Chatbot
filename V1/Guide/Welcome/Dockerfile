#Python 3.10 Slim 이미지를 기반으로 빌드
FROM python:3.10-slim

#작업 디렉토리 설정
WORKDIR /app

#필수 라이브러리 설치 (gcc 설치)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

#FastAPI 및 Uvicorn 설치  [requirements.txt 필요!]
RUN pip install --no-cache-dir fastapi uvicorn

# 5. 애플리케이션 코드 복사
COPY . .

# 6. FastAPI 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]