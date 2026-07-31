from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.db.session import init_db
from app.routers import auth, wallet, trade, staking, kyc, owner_admin, ads_payments

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    print(f"Starting {settings.PROJECT_NAME} v{settings.VERSION}...")
    try:
        await init_db()
        print("PostgreSQL Database tables verified/created successfully.")
    except Exception as e:
        print(f"DB Init note: {e}")
    yield
    # Shutdown logic
    print(f"Shutting down {settings.PROJECT_NAME}...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
)

# Set up CORS for Web & Mobile clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(wallet.router, prefix=settings.API_V1_STR)
app.include_router(trade.router, prefix=settings.API_V1_STR)
app.include_router(staking.router, prefix=settings.API_V1_STR)
app.include_router(kyc.router, prefix=settings.API_V1_STR)
app.include_router(owner_admin.router, prefix=settings.API_V1_STR)
app.include_router(ads_payments.router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "online",
        "owner_pin_protected": True,
        "docs_url": "/docs"
    }
