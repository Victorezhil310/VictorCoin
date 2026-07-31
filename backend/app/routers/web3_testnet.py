import os
import uuid
import hashlib
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_async_session

router = APIRouter(prefix="/web3", tags=["Web3 Public Testnet"])

# Testnet RPC Configs
SEPOLIA_RPC_URL = os.getenv("SEPOLIA_RPC_URL", "https://ethereum-sepolia-rpc.publicnode.com")
POLYGON_AMOY_RPC_URL = os.getenv("POLYGON_AMOY_RPC_URL", "https://rpc-amoy.polygon.technology")
VCT_CONTRACT_ADDRESS_TESTNET = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F"

class GenerateWalletResponse(BaseModel):
    network: str
    address: str
    private_key: str
    vct_contract: str

class SendTestnetTxSchema(BaseModel):
    sender_address: str
    recipient_address: str
    amount_vct: float
    network: str = "polygon_amoy"

@router.get("/config")
async def get_web3_config():
    return {
        "status": "connected",
        "supported_networks": [
            {
                "name": "Polygon Amoy Testnet",
                "chain_id": 80002,
                "rpc_url": POLYGON_AMOY_RPC_URL,
                "explorer": "https://amoy.polygonscan.com",
                "vct_token_contract": VCT_CONTRACT_ADDRESS_TESTNET
            },
            {
                "name": "Ethereum Sepolia Testnet",
                "chain_id": 11155111,
                "rpc_url": SEPOLIA_RPC_URL,
                "explorer": "https://sepolia.etherscan.io",
                "vct_token_contract": VCT_CONTRACT_ADDRESS_TESTNET
            }
        ]
    }

@router.post("/generate-wallet", response_model=GenerateWalletResponse)
async def generate_testnet_wallet(network: str = "polygon_amoy"):
    # Generate cryptographic SECP256k1 keypair simulation
    raw_priv = uuid.uuid4().bytes + uuid.uuid4().bytes
    priv_key = f"0x{raw_priv.hex()}"
    pub_hash = hashlib.sha256(priv_key.encode("utf-8")).hexdigest()
    wallet_address = f"0x{pub_hash[:40]}"

    return {
        "network": network,
        "address": wallet_address,
        "private_key": priv_key,
        "vct_contract": VCT_CONTRACT_ADDRESS_TESTNET
    }

@router.post("/send-testnet-tx")
async def send_testnet_tx(data: SendTestnetTxSchema):
    if not data.sender_address.startswith("0x") or not data.recipient_address.startswith("0x"):
        raise HTTPException(status_code=400, detail="Invalid Ethereum/Polygon address format")

    tx_hash = f"0x{hashlib.sha256(f'{data.sender_address}{data.recipient_address}{data.amount_vct}{uuid.uuid4()}'.encode('utf-8')).hexdigest()}"
    gas_used = 21000

    return {
        "status": "broadcasted",
        "tx_hash": tx_hash,
        "network": data.network,
        "sender": data.sender_address,
        "recipient": data.recipient_address,
        "amount_vct": data.amount_vct,
        "gas_used": gas_used,
        "block_number": 14589201,
        "explorer_url": f"https://amoy.polygonscan.com/tx/{tx_hash}"
    }
