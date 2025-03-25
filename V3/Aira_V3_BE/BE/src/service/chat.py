import os
import httpx
from models.chat import ChatRequest
from fastapi import HTTPException

# Retrieve GPT Worker URL from environment variables
GPT_WORKER_URL = os.getenv("GPT_WORKER_URL")

async def generate_text(chat_request: ChatRequest) -> dict:
    payload = {
        "prompt": chat_request.prompt,
        "max_tokens": chat_request.max_tokens,
        "temperature": chat_request.temperature
    }
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(GPT_WORKER_URL, json=payload)
        
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail=f"GPT Worker 호출 실패: {response.text}")
        # The GPT worker returns {"request_id": "...", "result": <gpt_response>}
        # Transform this so that the backend returns an object with key "response"
        worker_data = response.json()
        try:
            chat_text = worker_data["result"]["choices"][0]["message"]["content"]
        except Exception as parse_err:
            raise HTTPException(status_code=500, detail=f"응답 파싱 실패: {parse_err}")
        
        # Return a simplified response
        return {"response": chat_text}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API 호출 실패: {str(e)}")