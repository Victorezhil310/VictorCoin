import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import MiningSession, Wallet, Transaction, OwnerCommissionLog

router = APIRouter(prefix="/mining", tags=["Mining Engine"])

class BoostMiningSchema(BaseModel):
    user_id: int
    boost_type: str  # turbo_2x, quantum_5x

@router.get("/status/{user_id}")
async def get_mining_status(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(MiningSession).where(MiningSession.user_id == user_id)
    res = await session.execute(q)
    ms = res.scalars().first()

    if not ms:
        # Starter default mining session
        ms = MiningSession(user_id=user_id, hashrate_mhs=45.8, unclaimed_mined_vct=12.45, total_mined_vct=154.20)
        session.add(ms)
        await session.commit()
        await session.refresh(ms)

    return {
        "status": "active" if ms.is_mining else "paused",
        "hashrate_mhs": ms.hashrate_mhs * ms.boost_multiplier,
        "base_hashrate": ms.hashrate_mhs,
        "boost_multiplier": ms.boost_multiplier,
        "unclaimed_mined_vct": ms.unclaimed_mined_vct,
        "total_mined_vct": ms.total_mined_vct,
        "est_daily_vct": round((ms.hashrate_mhs * ms.boost_multiplier) * 0.54, 2),
        "owner_pool_tax_rate": "5%",
    }

@router.post("/claim/{user_id}")
async def claim_mined_rewards(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(MiningSession).where(MiningSession.user_id == user_id)
    res = await session.execute(q)
    ms = res.scalars().first()

    claim_amount = ms.unclaimed_mined_vct if ms and ms.unclaimed_mined_vct > 0 else 12.45

    # 5% Owner Commission Tax on Mining Rewards
    owner_tax_vct = claim_amount * 0.05
    user_net_vct = claim_amount - owner_tax_vct

    # Add to User Wallet
    w_q = select(Wallet).where(Wallet.user_id == user_id)
    w_res = await session.execute(w_q)
    wallet = w_res.scalars().first()

    if not wallet:
        wallet = Wallet(user_id=user_id, vct_balance=0.0)
        session.add(wallet)

    wallet.vct_balance += user_net_vct

    if ms:
        ms.total_mined_vct += claim_amount
        ms.unclaimed_mined_vct = 0.0

    # Log Owner Commission Entry
    comm_log = OwnerCommissionLog(
        commission_type="mining_pool_royalty",
        amount_vct=owner_tax_vct,
        amount_usd=owner_tax_vct * 0.2458,
        source_user_id=user_id,
    )
    session.add(comm_log)

    tx = Transaction(
        tx_hash=f"0x{uuid.uuid4().hex[:16]}",
        user_id=user_id,
        tx_type="mining_claim",
        asset="VCT",
        amount=user_net_vct,
        fee=owner_tax_vct,
        status="completed",
    )
    session.add(tx)

    await session.commit()

    return {
        "status": "success",
        "claimed_vct": user_net_vct,
        "owner_commission_tax_vct": owner_tax_vct,
        "new_balance": wallet.vct_balance,
    }

@router.post("/boost")
async def boost_mining_hashrate(
    data: BoostMiningSchema,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(MiningSession).where(MiningSession.user_id == data.user_id)
    res = await session.execute(q)
    ms = res.scalars().first()

    if not ms:
        ms = MiningSession(user_id=data.user_id)
        session.add(ms)

    multiplier = 2.0 if data.boost_type == "turbo_2x" else 5.0
    ms.boost_multiplier = multiplier
    await session.commit()

    return {
        "status": "success",
        "message": f"Mining Rig Hashrate Boosted to {multiplier}X!",
        "new_hashrate": ms.hashrate_mhs * multiplier
    }
