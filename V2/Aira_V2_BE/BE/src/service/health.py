from fastapi import HTTPException
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv(os.getenv("ENV_FILE",".env"))
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY",".env"))

def health_check_service():
    try:
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "system", "content": "Health check."}],
            max_tokens=5
        )
        return {"status": "healthy", "response": response.choices[0].message.content}
    except Exception as e:
        raise HTTPException(status_code=500, detail="ChatGPT API is not reachable.") 