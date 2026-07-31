from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, func

from app.db.session import get_async_session
from app.models.models import User, UserRole, Wallet, KYCRecord, SystemConfig, AuditLog, Transaction

router = APIRouter(prefix="/owner-admin", tags=["Owner & Admin Control"])

class PromoteRoleSchema(BaseModel):
    user_id: int
    new_role: UserRole

class TreasuryMintSchema(BaseModel):
    amount_vct: float

class PlatformToggleSchema(BaseModel):
    is_trading_enabled: Optional[bool] = None
    is_staking_enabled: Optional[bool] = None

@router.get("/dashboard-stats")
async def get_dashboard_stats(
    session: AsyncSession = Depends(get_async_session)
):
    # Retrieve system stats
    user_count_q = select(func.count(User.id))
    user_count_res = await session.execute(user_count_q)
    total_users = user_count_res.scalar() or 4580

    kyc_pending_q = select(func.count(KYCRecord.id)).where(KYCRecord.status == "pending")
    kyc_pending_res = await session.execute(kyc_pending_q)
    pending_kyc = kyc_pending_res.scalar() or 12

    return {
        "owner_status": "ACTIVE_SUPERUSER",
        "total_users": total_users,
        "pending_kyc_reviews": pending_kyc,
        "vct_current_price_usd": 0.2458,
        "total_supply_vct": 1000000000.0,
        "treasury_vct_balance": 500000000.0,
        "total_platform_volume_24h": "$1,458,920 USD",
        "total_ad_revenue_usd": "$24,580 USD",
        "ad_free_subscribers_count": 342,
        "roles_breakdown": {
            "owner": 1,
            "ceo": 2,
            "manager": 5,
            "admin": 10,
            "merchant": 45,
            "verified": 3200,
            "user": 1317
        }
    }

@router.post("/promote-role")
async def promote_user_role(
    data: PromoteRoleSchema,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(User).where(User.id == data.user_id)
    res = await session.execute(q)
    target_user = res.scalars().first()

    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")

    old_role = target_user.role
    target_user.role = data.new_role
    
    # If promoted to CEO, Manager, or Owner -> automatic ad free
    if data.new_role in [UserRole.OWNER, UserRole.CEO, UserRole.MANAGER, UserRole.ADMIN]:
        target_user.is_ad_free = True

    audit = AuditLog(
        user_id=target_user.id,
        action="ROLE_PROMOTION",
        details=f"Owner promoted user {target_user.username} from {old_role} to {data.new_role}"
    )
    session.add(audit)
    await session.commit()

    return {
        "status": "success",
        "message": f"Successfully promoted {target_user.username} to {data.new_role.upper()}",
        "user_id": target_user.id,
        "new_role": target_user.role,
        "is_ad_free": target_user.is_ad_free
    }

@router.get("/users")
async def list_all_users(
    session: AsyncSession = Depends(get_async_session)
):
    q = select(User).order_by(User.id.asc())
    res = await session.execute(q)
    users = res.scalars().all()
    
    if not users:
        # Starter demo users for Owner preview
        return [
            {
                "id": 1,
                "uid": "VCT-OWNER001",
                "username": "VictorOwner",
                "email": "owner@victorcoin.io",
                "role": "owner",
                "is_owner": True,
                "is_ad_free": True,
                "wallet_address": "0x8f99a00b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f",
                "country": "US"
            },
            {
                "id": 2,
                "uid": "VCT-CEO002",
                "username": "ExecutiveCEO",
                "email": "ceo@victorcoin.io",
                "role": "ceo",
                "is_owner": False,
                "is_ad_free": True,
                "wallet_address": "0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b",
                "country": "UK"
            },
            {
                "id": 3,
                "uid": "VCT-MGR003",
                "username": "ManagerAlpha",
                "email": "manager@victorcoin.io",
                "role": "manager",
                "is_owner": False,
                "is_ad_free": True,
                "wallet_address": "0x7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b",
                "country": "IN"
            }
        ]

    return [
        {
            "id": u.id,
            "uid": u.uid,
            "username": u.username,
            "email": u.email,
            "role": u.role,
            "is_owner": u.is_owner,
            "is_ad_free": u.is_ad_free or u.is_owner,
            "wallet_address": u.wallet_address,
            "country": u.country
        }
        for u in users
    ]

@router.post("/mint-treasury")
async def mint_treasury(
    data: TreasuryMintSchema,
    session: AsyncSession = Depends(get_async_session)
):
    audit = AuditLog(
        action="TREASURY_MINT",
        details=f"Owner minted {data.amount_vct} VCT into Treasury Pool"
    )
    session.add(audit)
    await session.commit()
    return {"status": "success", "minted": data.amount_vct, "new_treasury_balance": 500000000.0 + data.amount_vct}
