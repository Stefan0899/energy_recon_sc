const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x4A679253410272dd5232B3Ff7cF5dbB88f295319"; // Replace with actual contract address
    const providerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // Provider1
    const user1Address = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // User1
    const user2Address = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"; // User2

    const ContractFactory = await ethers.getContractFactory("SimplePayment");
    const contract = await ContractFactory.attach(contractAddress);

    console.log("\n🛠 Checking Wallet & Contract Balances...");

    // 🔹 Step 1: Get Wallet Balances
    console.log("\n🔍 Checking Wallet Balances:");
    const providerBalance = await ethers.provider.getBalance(providerAddress);
    const user1Balance = await ethers.provider.getBalance(user1Address);
    const user2Balance = await ethers.provider.getBalance(user2Address);
    console.log(`💰 Provider Balance: ${ethers.formatEther(providerBalance)} ETH`);
    console.log(`💰 User1 Balance: ${ethers.formatEther(user1Balance)} ETH`);
    console.log(`💰 User2 Balance: ${ethers.formatEther(user2Balance)} ETH`);

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

