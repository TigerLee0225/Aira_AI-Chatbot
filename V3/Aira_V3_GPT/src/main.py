from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from service.chat import process_generate_request, process_messages

app = FastAPI()

class GenerateRequest(BaseModel):
    prompt: str
    max_tokens: int
    temperature: float

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.post("/generate/")
async def generate_endpoint(request: GenerateRequest):
    try:
        result = process_generate_request(request)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"GPT Worker 호출 실패: {str(e)}")

#Launch background SQS processor on startup
@app.on_event("startup")
async def startup_event():
    import asyncio
    asyncio.create_task(process_messages())

if __name__ == "__main__":
    import uvicorn
    print("Starting GPT Worker with FastAPI...")
    uvicorn.run("main:app", host="0.0.0.0", port=9000, log_level="debug")