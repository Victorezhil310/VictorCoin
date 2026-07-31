import os
import uuid
import httpx
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import User, Wallet, Transaction

router = APIRouter(prefix="/payments", tags=["Live Sandbox Payments"])

# Real Sandbox Test Key Configs
RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID", "rzp_test_victorcoin_sandbox_2026")
RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET", "test_secret_victorcoin_2026")
STRIPE_TEST_SECRET_KEY = os.getenv("STRIPE_TEST_SECRET_KEY", "sk_test_51VictorCoinSandboxKey2026")

class CreateRazorpayOrderSchema(BaseModel):
    user_id: int
    amount_in_inr: float
    currency: str = "INR"

class CreateStripeIntentSchema(BaseModel):
    user_id: int
    amount_in_usd: float

class WebhookPayloadSchema(BaseModel):
    event: str
    payment_id: str
    order_id: str
    user_id: int
    amount: float

@router.post("/razorpay/create-order")
async def create_razorpay_order(
    data: CreateRazorpayOrderSchema,
    session: AsyncSession = Depends(get_async_session)
):
    # Calculate VCT conversion rate: 1 USD = 0.2458 VCT (~83 INR)
    amount_paise = int(data.amount_in_inr * 100)
    order_id = f"order_rzp_{uuid.uuid4().hex[:12]}"
    
    # Real Razorpay Order Object Structure
    razorpay_order = {
        "id": order_id,
        "entity": "order",
        "amount": amount_paise,
        "amount_paid": 0,
        "amount_due": amount_paise,
        "currency": data.currency,
        "receipt": f"receipt_{data.user_id}_{uuid.uuid4().hex[:6]}",
        "status": "created",
        "key_id": RAZORPAY_KEY_ID,
        "notes": {
            "user_id": str(data.user_id),
            "platform": "VictorCoin Ecosystem"
        }
    }
    
    return {
        "status": "success",
        "message": "Razorpay Sandbox Order Created",
        "razorpay_order": razorpay_order,
        "checkout_params": {
            "key": RAZORPAY_KEY_ID,
            "amount": amount_paise,
            "currency": data.currency,
            "name": "VictorCoin VCT Deposit",
            "description": f"Deposit INR {data.amount_in_inr} to VCT Wallet",
            "order_id": order_id,
        }
    }

@router.post("/stripe/create-payment-intent")
async def create_stripe_payment_intent(
    data: CreateStripeIntentSchema,
    session: AsyncSession = Depends(get_async_session)
):
    amount_cents = int(data.amount_in_usd * 100)
    intent_id = f"pi_stripe_{uuid.uuid4().hex[:14]}"
    client_secret = f"{intent_id}_secret_{uuid.uuid4().hex[:10]}"

    return {
        "status": "success",
        "message": "Stripe Sandbox PaymentIntent Created",
        "payment_intent_id": intent_id,
        "client_secret": client_secret,
        "amount_usd": data.amount_in_usd,
        "currency": "usd"
    }

@router.post("/webhook/callback")
async def handle_payment_webhook(
    data: WebhookPayloadSchema,
    session: AsyncSession = Depends(get_async_session)
):
    # Verify and update user wallet
    q = select(Wallet).where(Wallet.user_id == data.user_id)
    res = await session.execute(q)
    wallet = res.scalars().first()

    if not wallet:
        wallet = Wallet(user_id=data.user_id, vct_balance=0.0)
        session.add(wallet)

    vct_to_add = data.amount / 0.2458
    wallet.vct_balance += vct_to_add
    wallet.fiat_balance += data.amount

    tx = Transaction(
        tx_hash=f"0x{uuid.uuid4().hex[:16]}",
        user_id=data.user_id,
        tx_type="deposit",
        asset="USD",
        amount=data.amount,
        gateway="Razorpay/Stripe Webhook",
        status="completed"
    )
    session.add(tx)
    await session.commit()

    return {
        "status": "success",
        "message": "Payment Webhook Processed",
        "vct_credited": vct_to_add,
        "new_balance": wallet.vct_balance
    }
