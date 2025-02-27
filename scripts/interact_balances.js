const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0xfcDB4564c18A9134002b9771816092C9693622e3"; // Replace with actual contract address
    const providerAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // Provider1


    const ContractFactory = await ethers.getContractFactory("SimplePayment");

    console.log("\n🛠 Checking Wallet & Contract Balances...");

    // 🔹 Step 1: Get Wallet Balances
    console.log("\n🔍 Checking Wallet Balances:");
    const providerBalance = await ethers.provider.getBalance(providerAddress);
    console.log(`💰 Provider Balance: ${ethers.formatEther(providerBalance)} ETH`);

    // 🔹 Step 2: Get Smart Contract Balance
    const contractBalance = await ethers.provider.getBalance(contractAddress);
    console.log(`🏦 Smart Contract Balance: ${ethers.formatEther(contractBalance)} ETH`);

    console.log("\n✅ Done! All balances checked.");
}

// Run the script
main().catch((error) => {
    console.error("❌ Error:", error);
    process.exit(1);
});

