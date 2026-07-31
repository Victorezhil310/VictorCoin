import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    verify_owner_pin,
)
from app.db.session import get_async_session
from app.models.models import User, Wallet, UserRole

router = APIRouter(prefix="/auth", tags=["Auth"])

class UserRegisterSchema(BaseModel):
    username: str
    email: EmailStr
    password: str
    phone_number: Optional[str] = None
    referral_code: Optional[str] = None

class UserLoginSchema(BaseModel):
    email: str
    password: str

class OwnerPinAuthSchema(BaseModel):
    pin: str

class TokenResponseSchema(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

@router.post("/register", response_model=TokenResponseSchema)
async def register(
    data: UserRegisterSchema,
    session: AsyncSession = Depends(get_async_session)
):
    # Check existing user
    query = select(User).where((User.email == data.email) | (User.username == data.username))
    res = await session.execute(query)
    if res.scalars().first():
        raise HTTPException(status_code=400, detail="User with this email or username already exists")
    
    uid = f"VCT-{uuid.uuid4().hex[:8].upper()}"
    wallet_addr = f"0x{uuid.uuid4().hex[:40]}"
    ref_code = f"REF{uuid.uuid4().hex[:6].upper()}"

    user = User(
        uid=uid,
        username=data.username,
        email=data.email,
        hashed_password=get_password_hash(data.password),
        phone_number=data.phone_number,
        wallet_address=wallet_addr,
        referral_code=ref_code,
        referred_by=data.referral_code,
        role=UserRole.USER,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)

    # Initialize Wallet with initial bonus balance
    wallet = Wallet(user_id=user.id, vct_balance=12458.75, usdt_balance=100.25, fiat_balance=8742.58)
    session.add(wallet)
    await session.commit()

    token = create_access_token(subject=user.id, extra_claims={"role": user.role.value, "uid": user.uid})
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "uid": user.uid,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "wallet_address": user.wallet_address,
            "referral_code": user.referral_code,
            "is_owner": user.is_owner,
            "is_ad_free": user.is_ad_free,
        }
    }

@router.post("/login", response_model=TokenResponseSchema)
async def login(
    data: UserLoginSchema,
    session: AsyncSession = Depends(get_async_session)
):
    query = select(User).where(User.email == data.email)
    res = await session.execute(query)
    user = res.scalars().first()

    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token(
        subject=user.id,
        extra_claims={"role": user.role.value, "uid": user.uid, "is_owner": user.is_owner}
    )
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "uid": user.uid,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "wallet_address": user.wallet_address,
            "referral_code": user.referral_code,
            "is_owner": user.is_owner,
            "is_ad_free": user.is_ad_free or user.is_owner,
        }
    }

@router.post("/owner-pin-login")
async def owner_pin_login(data: OwnerPinAuthSchema):
    if not verify_owner_pin(data.pin):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access Denied: Invalid Owner Security PIN"
        )
    
    # Generate super elevated owner JWT token
    token = create_access_token(
        subject="OWNER_SUPERUSER",
        extra_claims={"role": UserRole.OWNER.value, "is_owner": True, "is_elevated": True}
    )
    return {
        "status": "success",
        "message": "Owner Access Granted",
        "access_token": token,
        "role": "owner",
        "is_owner": True,
        "is_ad_free": True
    }
