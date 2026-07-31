from datetime import datetime, timezone, timedelta
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import StakingPosition, StakingType, Wallet, Transaction

router = APIRouter(prefix="/staking", tags=["Staking"])

class StakeRequestSchema(BaseModel):
    user_id: int
    staking_type: StakingType
    amount: float
    auto_compound: bool = True

@router.get("/pools")
async def get_staking_pools():
    return [
        {
            "id": "flexible",
            "name": "Flexible Staking",
            "apy": 8.5,
            "lock_days": 0,
            "min_amount": 100,
            "description": "Earn daily rewards with instant withdrawal flexibility."
        },
        {
            "id": "locked_30d",
            "name": "30 Days Vault",
            "apy": 12.0,
            "lock_days": 30,
            "min_amount": 500,
            "description": "Enhanced yields for short term lockers."
        },
        {
            "id": "locked_90d",
            "name": "90 Days Gold Vault",
            "apy": 15.2,
            "lock_days": 90,
            "min_amount": 1000,
            "description": "High yield staking pool for long term supporters."
        },
        {
            "id": "locked_365d",
            "name": "365 Days Diamond Vault",
            "apy": 18.5,
            "lock_days": 365,
            "min_amount": 2500,
            "description": "Maximum reward pool: Earn up to 18.5% APY."
        },
    ]

@router.post("/stake")
async def create_staking_position(
    data: StakeRequestSchema,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(Wallet).where(Wallet.user_id == data.user_id)
    res = await session.execute(q)
    wallet = res.scalars().first()

    if not wallet or wallet.vct_balance < data.amount:
        raise HTTPException(status_code=400, detail="Insufficient VCT balance to stake")

    # Determine APY & duration
    apy_map = {
        StakingType.FLEXIBLE: 8.5,
        StakingType.LOCKED_30D: 12.0,
        StakingType.LOCKED_90D: 15.2,
        StakingType.LOCKED_365D: 18.5,
    }
    days_map = {
        StakingType.FLEXIBLE: 0,
        StakingType.LOCKED_30D: 30,
        StakingType.LOCKED_90D: 90,
        StakingType.LOCKED_365D: 365,
    }

    apy = apy_map.get(data.staking_type, 8.5)
    days = days_map.get(data.staking_type, 0)
    end_date = datetime.now(timezone.utc) + timedelta(days=days) if days > 0 else None

    # Move from free balance to locked balance
    wallet.vct_balance -= data.amount
    wallet.vct_locked += data.amount

    pos = StakingPosition(
        user_id=data.user_id,
        staking_type=data.staking_type,
        staked_amount=data.amount,
        apy_percentage=apy,
        earned_rewards=0.0,
        auto_compound=data.auto_compound,
        end_date=end_date,
    )
    session.add(pos)
    await session.commit()
    await session.refresh(pos)

    return {
        "status": "success",
        "message": f"Successfully staked {data.amount} VCT at {apy}% APY",
        "position": pos,
        "remaining_free_vct": wallet.vct_balance
    }

@router.get("/positions/{user_id}")
async def get_user_positions(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(StakingPosition).where(StakingPosition.user_id == user_id, StakingPosition.is_active == True)
    res = await session.execute(q)
    positions = res.scalars().all()
    
    if not positions:
        # Default starter mock position for demo display
        return [
            {
                "id": 1,
                "user_id": user_id,
                "staking_type": "locked_365d",
                "staked_amount": 1500.0,
                "apy_percentage": 18.5,
                "earned_rewards": 145.85,
                "auto_compound": True,
                "is_active": True,
                "start_date": "2026-06-01T00:00:00Z"
            }
        ]
    return positions

@router.post("/claim/{position_id}")
async def claim_staking_rewards(
    position_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(StakingPosition).where(StakingPosition.id == position_id)
    res = await session.execute(q)
    pos = res.scalars().first()

    if not pos:
        raise HTTPException(status_code=44, detail="Staking position not found")

    rewards_to_claim = pos.earned_rewards or 25.50  # Simulated rewards claim
    pos.earned_rewards = 0.0

    # Add rewards to user wallet
    w_q = select(Wallet).where(Wallet.user_id == pos.user_id)
    w_res = await session.execute(w_q)
    wallet = w_res.scalars().first()
    if wallet:
        wallet.vct_balance += rewards_to_claim

    await session.commit()
    return {"status": "success", "claimed_vct": rewards_to_claim}
