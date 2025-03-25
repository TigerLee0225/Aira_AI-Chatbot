from sqlalchemy import Column, Integer, String, VARCHAR
from sqlalchemy.orm import relationship
from db.database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(VARCHAR(50), unique=True, index=True, nullable=False)
    email = Column(VARCHAR(100), unique=True, index=True, nullable=False)
    hashed_password = Column(VARCHAR(255), nullable=False)
    answers = relationship("Answer", back_populates="user")
