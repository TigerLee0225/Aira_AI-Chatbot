from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from models.user import User
from schemas import user_schema
from utils import hash_password, verify_password, create_access_token
from jose import JWTError, jwt
import utils

def register(user: user_schema.UserCreate, db: Session):

    # 사용자 중복 확인
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(status_code=400, detail="Username already registered")
    if db.query(User).filter(User.email == user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
  
    hashed_password = hash_password(user.password)
    db_user = User(username=user.username, email=user.email, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Return a response that matches the UserResponse schema
    return user_schema.UserResponse(id=db_user.id, username=db_user.username, email=db_user.email)

def login(user: user_schema.UserLogin, db: Session):
    print(f"Login attempt with email: {user.email}")
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user:
        print("User not found")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not verify_password(user.password, db_user.hashed_password):
        print("Invalid password")
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": db_user.username})
    return {"access_token": access_token, "token_type": "bearer"}

def read_users_me(token: str, db: Session):
    try:
        payload = jwt.decode(token, utils.SECRET_KEY, algorithms=[utils.ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError as e:
        print(f"JWT Error: {str(e)}")  # 오류 로그 추가
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user
