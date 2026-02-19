from fastapi import FastAPI, HTTPException, Depends
from app.schemas import RegisterRequest, LoginRequest, UserResponse
from app.models import User
from app.database import users_collection
from app.auth import hash_password, verify_password, create_access_token
from bson import ObjectId
from app.auth import get_current_user

app = FastAPI(title="User Service")

HARD_CODED_OTP = "1234"

@app.post("/register", response_model=UserResponse)
def register(req: RegisterRequest):
    if req.otp != HARD_CODED_OTP:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if users_collection.find_one({"email": req.email}):
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pw = hash_password(req.password)
    user = User(name=req.name, email=req.email, password=hashed_pw)
    users_collection.insert_one(user.dict())
    return UserResponse(name=user.name, email=user.email, created_at=str(user.created_at))

@app.post("/login")
def login(req: LoginRequest):
    user = users_collection.find_one({"email": req.email})
    if not user or not verify_password(req.password, user["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": str(user["_id"])})
    return {"access_token": token, "token_type": "bearer"}

@app.get("/profile", response_model=UserResponse)
def profile(current_user: dict = Depends(get_current_user)):
    return UserResponse(
        name=current_user["name"],
        email=current_user["email"],
        created_at=str(current_user["created_at"])
    )   
