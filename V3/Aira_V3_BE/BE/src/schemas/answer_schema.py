from pydantic import BaseModel
from datetime import datetime

class AnswerCreate(BaseModel):
    answer1: int
    answer2: int
    answer3: int
    answer4: int
    answer5: int

class AnswerResponse(AnswerCreate):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True