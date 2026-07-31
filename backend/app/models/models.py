from datetime import datetime, timezone
from enum import Enum
from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship

class UserRole(str, Enum):
    GUEST = "guest"
    USER = "user"
    VERIFIED = "verified"
    MERCHANT = "merchant"
    ADMIN = "admin"
    MANAGER = "manager"
    CEO = "ceo"
    OWNER = "owner"

class KYCStatus(str, Enum):
    UNSUBMITTED = "unsubmitted"
    PENDING = "pending"
    AUTO_APPROVED = "auto_approved"
    MANUALLY_APPROVED = "manually_approved"
    REJECTED = "rejected"

class OrderType(str, Enum):
    MARKET = "market"
    LIMIT = "limit"
    STOP = "stop"

class OrderSide(str, Enum):
    BUY = "buy"
    SELL = "sell"

class StakingType(str, Enum):
    FLEXIBLE = "flexible"
    LOCKED_30D = "locked_30d"
    LOCKED_90D = "locked_90d"
    LOCKED_365D = "locked_365d"

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    uid: str = Field(index=True, unique=True)
    username: str = Field(index=True, unique=True)
    email: str = Field(index=True, unique=True)
    hashed_password: str
    phone_number: Optional[str] = Field(default=None)
    role: UserRole = Field(default=UserRole.USER)
    is_owner: bool = Field(default=False)
    is_ad_free: bool = Field(default=False) # Owner and subscribers are ad-free
    avatar_url: Optional[str] = Field(default=None)
    wallet_address: str = Field(index=True, unique=True)
    referral_code: str = Field(index=True, unique=True)
    referred_by: Optional[str] = Field(default=None)
    country: str = Field(default="US")
    language: str = Field(default="en")
    security_level: int = Field(default=1)  # 1 to 5
    is_2fa_enabled: bool = Field(default=False)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class Wallet(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    vct_balance: float = Field(default=0.0)
    vct_locked: float = Field(default=0.0)
    fiat_balance: float = Field(default=0.0)  # USD
    usdt_balance: float = Field(default=100.0) # Starting testnet/live paper balance
    btc_balance: float = Field(default=0.0)
    eth_balance: float = Field(default=0.0)
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class Transaction(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    tx_hash: str = Field(index=True, unique=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    tx_type: str = Field(index=True)  # send, receive, deposit, withdraw, staking_reward, referral_reward
    asset: str = Field(default="VCT") # VCT, USD, BTC, ETH
    amount: float
    fee: float = Field(default=0.0)
    recipient_address: Optional[str] = None
    sender_address: Optional[str] = None
    status: str = Field(default="completed")  # pending, completed, failed
    gateway: Optional[str] = None # Razorpay, Paytm, PhonePe, UPI, Bank Transfer
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class KYCRecord(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    document_type: str  # Aadhaar, Passport, Driving License, National ID
    document_number: str
    document_front_url: Optional[str] = None
    document_back_url: Optional[str] = None
    selfie_url: Optional[str] = None
    liveness_verified: bool = Field(default=False)
    status: KYCStatus = Field(default=KYCStatus.PENDING)
    rejection_reason: Optional[str] = None
    verified_at: Optional[datetime] = None
    submitted_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class TradingOrder(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    symbol: str = Field(default="VCT/USDT", index=True)
    side: OrderSide
    order_type: OrderType
    price: float
    amount: float
    total: float
    status: str = Field(default="filled")  # open, filled, cancelled
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class StakingPosition(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    staking_type: StakingType
    staked_amount: float
    apy_percentage: float  # e.g., 18.5
    earned_rewards: float = Field(default=0.0)
    auto_compound: bool = Field(default=True)
    is_active: bool = Field(default=True)
    start_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    end_date: Optional[datetime] = None

class SupportTicket(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    subject: str
    message: str
    category: str = Field(default="General")
    status: str = Field(default="open")  # open, in_progress, resolved
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class AuditLog(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: Optional[int] = None
    action: str
    details: str
    ip_address: Optional[str] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class SystemConfig(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    vct_current_price: float = Field(default=0.2458)
    total_staked_vct: float = Field(default=1250000.0)
    total_users_count: int = Field(default=4500)
    treasury_vct_balance: float = Field(default=500000000.0)
    is_trading_enabled: bool = Field(default=True)
    is_staking_enabled: bool = Field(default=True)
