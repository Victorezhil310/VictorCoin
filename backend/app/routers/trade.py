import random
from datetime import datetime, timezone, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.db.session import get_async_session
from app.models.models import TradingOrder, OrderSide, OrderType, Wallet

router = APIRouter(prefix="/trade", tags=["Trading"])

class PlaceOrderSchema(BaseModel):
    user_id: int
    symbol: str = "VCT/USDT"
    side: OrderSide  # buy, sell
    order_type: OrderType  # market, limit
    price: float
    amount: float

@router.get("/markets")
async def get_market_overview():
    return [
        {
            "symbol": "VCT/USDT",
            "name": "VictorCoin",
            "code": "VCT",
            "price": 0.2458,
            "change_24h": 8.32,
            "volume_24h": "1.45M",
            "is_featured": True,
        },
        {
            "symbol": "BTC/USDT",
            "name": "Bitcoin",
            "code": "BTC",
            "price": 67245.32,
            "change_24h": 3.21,
            "volume_24h": "42.1B",
            "is_featured": False,
        },
        {
            "symbol": "ETH/USDT",
            "name": "Ethereum",
            "code": "ETH",
            "price": 3245.67,
            "change_24h": 2.45,
            "volume_24h": "18.6B",
            "is_featured": False,
        },
        {
            "symbol": "BNB/USDT",
            "name": "BNB",
            "code": "BNB",
            "price": 592.35,
            "change_24h": 1.23,
            "volume_24h": "4.2B",
            "is_featured": False,
        },
        {
            "symbol": "SOL/USDT",
            "name": "Solana",
            "code": "SOL",
            "price": 142.36,
            "change_24h": 4.87,
            "volume_24h": "6.8B",
            "is_featured": False,
        },
        {
            "symbol": "XRP/USDT",
            "name": "XRP",
            "code": "XRP",
            "price": 0.6123,
            "change_24h": -1.25,
            "volume_24h": "1.9B",
            "is_featured": False,
        },
        {
            "symbol": "ADA/USDT",
            "name": "Cardano",
            "code": "ADA",
            "price": 0.4521,
            "change_24h": 2.01,
            "volume_24h": "980M",
            "is_featured": False,
        },
    ]

@router.get("/candles/{symbol}")
async def get_candles(symbol: str, timeframe: str = "1D"):
    # Generate realistic candlestick data for charts
    base_price = 0.2458 if "VCT" in symbol else (67000 if "BTC" in symbol else 3200)
    candles = []
    now = datetime.now(timezone.utc)
    
    for i in range(30, 0, -1):
        dt = now - timedelta(days=i)
        variation = random.uniform(-0.03, 0.04)
        open_p = base_price * (1 + variation)
        close_p = open_p * (1 + random.uniform(-0.02, 0.03))
        high_p = max(open_p, close_p) * (1 + random.uniform(0.001, 0.015))
        low_p = min(open_p, close_p) * (1 - random.uniform(0.001, 0.015))
        candles.append({
            "timestamp": dt.strftime("%Y-%m-%d"),
            "open": round(open_p, 4),
            "high": round(high_p, 4),
            "low": round(low_p, 4),
            "close": round(close_p, 4),
            "volume": random.randint(10000, 500000)
        })
        base_price = close_p
        
    return candles

@router.post("/order")
async def place_order(
    data: PlaceOrderSchema,
    session: AsyncSession = Depends(get_async_session)
):
    total_cost = data.price * data.amount
    
    # Verify wallet
    q = select(Wallet).where(Wallet.user_id == data.user_id)
    res = await session.execute(q)
    wallet = res.scalars().first()

    if data.side == OrderSide.BUY:
        if not wallet or wallet.usdt_balance < total_cost:
            raise HTTPException(status_code=400, detail="Insufficient USDT balance for order")
        wallet.usdt_balance -= total_cost
        wallet.vct_balance += data.amount
    else:
        if not wallet or wallet.vct_balance < data.amount:
            raise HTTPException(status_code=400, detail="Insufficient VCT balance for order")
        wallet.vct_balance -= data.amount
        wallet.usdt_balance += total_cost

    order = TradingOrder(
        user_id=data.user_id,
        symbol=data.symbol,
        side=data.side,
        order_type=data.order_type,
        price=data.price,
        amount=data.amount,
        total=total_cost,
        status="filled",
    )
    session.add(order)
    await session.commit()
    await session.refresh(order)

    return {
        "status": "success",
        "message": f"Order executed: {data.side.upper()} {data.amount} {data.symbol} @ {data.price}",
        "order": order,
        "new_vct_balance": wallet.vct_balance,
        "new_usdt_balance": wallet.usdt_balance
    }

@router.get("/orders/{user_id}")
async def get_user_orders(
    user_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    q = select(TradingOrder).where(TradingOrder.user_id == user_id).order_by(TradingOrder.created_at.desc())
    res = await session.execute(q)
    orders = res.scalars().all()
    return orders
