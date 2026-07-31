import os

class Settings:
    PROJECT_NAME: str = "VictorCoin API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "victorcoin_super_secret_jwt_key_2026_production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Owner Security Pin (Default "888888")
    OWNER_PIN_DEFAULT: str = os.getenv("OWNER_PIN_DEFAULT", "888888")
    
    # Database & Redis
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "victor_user")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "victor_password_2026")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "victorcoin_db")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        f"postgresql+asyncpg://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_SERVER}:{POSTGRES_PORT}/{POSTGRES_DB}"
    )
    
    REDIS_HOST: str = os.getenv("REDIS_HOST", "localhost")
    REDIS_PORT: int = int(os.getenv("REDIS_PORT", "6379"))
    
    # Coin Economics
    VCT_INITIAL_PRICE_USD: float = 0.2458
    VCT_TOTAL_SUPPLY: float = 1000000000.0  # 1 Billion VCT

settings = Settings()
