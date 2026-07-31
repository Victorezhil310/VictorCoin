import uuid
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import User, Wallet, Transaction

router = APIRouter(prefix="/monetization", tags=["Ads & Payments"])

class ClaimAdRewardSchema(BaseModel):
    user_id: int
    ad_unit_id: str  # banner, interstitial, rewarded

class SubscribeAdFreeSchema(BaseModel):
    user_id: int
    plan: str  # monthly_2.99, annual_19.99
    payment_gateway: str  # Razorpay, Paytm, PhonePe, UPI, Card

@router.post("/claim-rewarded-ad")
async def claim_rewarded_ad(
    data: ClaimAdRewardSchema,
    session: AsyncSession = Depends(get_async_session)
):
    reward_amount = 5.0  # 5 VCT reward per ad watched
    
    q = select(Wallet).where(Wallet.user_id == data.user_id)
    res = await session.execute(q)
    wallet = res.scalars().first()

    if not wallet:
        wallet = Wallet(user_id=data.user_id, vct_balance=0.0)
        session.add(wallet)

    wallet.vct_balance += reward_amount

    tx = Transaction(
        tx_hash=f"0x{uuid.uuid4().hex[:16]}",
        user_id=data.user_id,
        tx_type="ad_reward",
        asset="VCT",
        amount=reward_amount,
        status="completed"
    )
    session.add(tx)
    await session.commit()

    return {
        "status": "success",
        "reward_vct": reward_amount,
        "message": f"Rewarded ad watched! Added {reward_amount} VCT to wallet.",
        "new_balance": wallet.vct_balance
    }

@router.post("/subscribe-ad-free")
async def subscribe_ad_free(
    data: SubscribeAdFreeSchema,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(User).where(User.id == data.user_id)
    res = await session.execute(q)
    user = res.scalars().first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_ad_free = True
    await session.commit()

    return {
        "status": "success",
        "message": f"Successfully activated Ad-Free VIP Subscription via {data.payment_gateway}!",
        "is_ad_free": True
    }
