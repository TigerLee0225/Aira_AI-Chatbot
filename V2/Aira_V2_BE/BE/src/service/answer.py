from sqlalchemy.orm import Session
from models.answer import Answer
from schemas.answer_schema import AnswerCreate
from models.user import User

def save_answers(answer: AnswerCreate, db: Session, user_id: int):
    db_answer = Answer(**answer.dict(), user_id=user_id)
    db.add(db_answer)
    db.commit()
    db.refresh(db_answer)
    return db_answer