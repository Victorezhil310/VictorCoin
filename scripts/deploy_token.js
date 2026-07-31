const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying VictorCoin (VCT) ERC-20 Smart Contract...");

  const [deployer] = await hre.ethers.getSigners();
  console.log("📍 Deployer Account Address:", deployer.address);
  console.log("💰 Account Balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  const VictorCoin = await hre.ethers.getContractFactory("VictorCoin");
  const victorCoin = await VictorCoin.deploy();

  await victorCoin.waitForDeployment();
  const tokenAddress = await victorCoin.getAddress();

  console.log("✅ VictorCoin (VCT) Deployed Successfully!");
  console.log("📄 Contract Address:", tokenAddress);
  console.log("👑 Owner Address:", await victorCoin.owner());
  console.log("📊 Total Supply:", (await victorCoin.totalSupply()).toString(), "VCT wei");
}

main().catch((error) => {
  console.error("❌ Deployment Failed:", error);
  process.exitCode = 1;
});
