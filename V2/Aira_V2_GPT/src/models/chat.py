from pydantic import BaseModel
from typing import List, Optional

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    prompt: str
    max_tokens: int = 2000
    temperature: float = 0.7

class ChatResponse(BaseModel):
    response: str