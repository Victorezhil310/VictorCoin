import pytest
from app.core.security import verify_owner_pin, get_password_hash, verify_password

def test_owner_pin_verification():
    assert verify_owner_pin("888888") is True
    assert verify_owner_pin("000000") is False

def test_password_hashing():
    pwd = "VictorSecretPass123!"
    hashed = get_password_hash(pwd)
    assert verify_password(pwd, hashed) is True
    assert verify_password("WrongPass", hashed) is False

def test_vct_staking_math():
    staked_vct = 1500.0
    apy = 18.5
    daily_yield = (staked_vct * (apy / 100)) / 365
    assert round(daily_yield, 2) == 0.76
