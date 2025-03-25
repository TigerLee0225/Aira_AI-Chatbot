from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from db.database import Base

class Answer(Base):
    __tablename__ = "answers"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    answer1 = Column(Integer, nullable=False)
    answer2 = Column(Integer, nullable=False)
    answer3 = Column(Integer, nullable=False)
    answer4 = Column(Integer, nullable=False)
    answer5 = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())  # 작성 시간 추가
    user = relationship("User", back_populates="answers")  # 이 부분이 필요합니다.
