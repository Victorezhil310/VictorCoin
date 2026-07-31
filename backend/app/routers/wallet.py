import uuid
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import User, Wallet, Transaction

router = APIRouter(prefix="/wallet", tags=["Wallet"])

class TransferSchema(BaseModel):
    recipient_address: str
    amount: float
    asset: str = "VCT"

class GatewayDepositSchema(BaseModel):
    amount: float
    gateway: str  # Razorpay, UPI, Paytm, PhonePe, Bank Transfer

@router.get("/summary/{user_id}")
async def get_wallet_summary(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    query = select(Wallet).where(Wallet.user_id == user_id)
    res = await session.execute(query)
    wallet = res.scalars().first()

    if not wallet:
        # Default mock wallet for instant view if user 1
        wallet = Wallet(user_id=user_id, vct_balance=12458.75, vct_locked=1500.0, usdt_balance=100.25, fiat_balance=8742.58)
    
    return {
        "vct_balance": wallet.vct_balance,
        "vct_locked": wallet.vct_locked,
        "vct_available": wallet.vct_balance - wallet.vct_locked,
        "fiat_balance_usd": wallet.fiat_balance,
        "usdt_balance": wallet.usdt_balance,
        "vct_usd_value": wallet.vct_balance * 0.2458,
        "24h_change_percent": 12.5,
    }

@router.post("/send/{user_id}")
async def send_vct(
    user_id: int,
    data: TransferSchema,
    session: AsyncSession = Depends(get_async_session)
):
    query = select(Wallet).where(Wallet.user_id == user_id)
    res = await session.execute(query)
    sender_wallet = res.scalars().first()

    if not sender_wallet or sender_wallet.vct_balance < data.amount:
        raise HTTPException(status_code=400, detail="Insufficient balance")

    sender_wallet.vct_balance -= data.amount
    
    # Try finding recipient
    rec_q = select(User).where(User.wallet_address == data.recipient_address)
    rec_res = await session.execute(rec_q)
    rec_user = rec_res.scalars().first()

    if rec_user:
        rec_w_q = select(Wallet).where(Wallet.user_id == rec_user.id)
        rec_w_res = await session.execute(rec_w_q)
        rec_wallet = rec_w_res.scalars().first()
        if rec_wallet:
            rec_wallet.vct_balance += data.amount

    tx = Transaction(
        tx_hash=f"0x{uuid.uuid4().hex}",
        user_id=user_id,
        tx_type="send",
        asset=data.asset,
        amount=data.amount,
        recipient_address=data.recipient_address,
        status="completed",
    )
    session.add(tx)
    await session.commit()

    return {"status": "success", "tx_hash": tx.tx_hash, "new_balance": sender_wallet.vct_balance}

@router.post("/deposit/{user_id}")
async def deposit_fiat(
    user_id: int,
    data: GatewayDepositSchema,
    session: AsyncSession = Depends(get_async_session)
):
    query = select(Wallet).where(Wallet.user_id == user_id)
    res = await session.execute(query)
    wallet = res.scalars().first()

    if not wallet:
        wallet = Wallet(user_id=user_id, vct_balance=0.0)
        session.add(wallet)

    # Convert deposit into VCT at rate $0.2458
    added_vct = data.amount / 0.2458
    wallet.vct_balance += added_vct
    wallet.fiat_balance += data.amount

    tx = Transaction(
        tx_hash=f"0x{uuid.uuid4().hex}",
        user_id=user_id,
        tx_type="deposit",
        asset="USD",
        amount=data.amount,
        gateway=data.gateway,
        status="completed",
    )
    session.add(tx)
    await session.commit()

    return {"status": "success", "tx_hash": tx.tx_hash, "added_vct": added_vct, "new_balance": wallet.vct_balance}

@router.get("/transactions/{user_id}")
async def get_transactions(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    query = select(Transaction).where(Transaction.user_id == user_id).order_by(Transaction.created_at.desc())
    res = await session.execute(query)
    txs = res.scalars().all()
    
    if not txs:
        # Provide clean initial mock transactions
        return [
            {
                "tx_hash": "0x8f2a9b3d1c4e7f",
                "tx_type": "deposit",
                "asset": "VCT",
                "amount": 5000.0,
                "status": "completed",
                "created_at": "2026-07-30T14:22:00Z"
            },
            {
                "tx_hash": "0x3e4f5a6b7c8d9e",
                "tx_type": "staking_reward",
                "asset": "VCT",
                "amount": 145.85,
                "status": "completed",
                "created_at": "2026-07-29T10:15:00Z"
            }
        ]
    return txs
