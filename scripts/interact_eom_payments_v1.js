require("dotenv").config();
const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
    const contractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // ✅ Replace with your deployed contract address
    const provider = new hre.ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    // ✅ Load the user’s private key from .env and create a wallet instance
    const userWallet = new hre.ethers.Wallet(process.env.OFFTAKER_PRIVATE_KEY, provider);

    console.log(`🔹 Using User Wallet: ${userWallet.address}`);

    // ✅ Get the contract instance connected to the user
    const contract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, userWallet);

    // ✅ Fetch assigned addresses
    const providerAddress = await contract.userProvider(userWallet.address);
    const distributorAddress = await contract.userDistributor(userWallet.address);
    const transmittorAddress = await contract.userTransmittor(userWallet.address);
    const generatorAddress = await contract.userGenerator(userWallet.address);

    console.log("🔹 Fetching ETH balances before transaction...");

    // ✅ Fetch ETH balances before the transaction
    const userBalanceBefore = await provider.getBalance(userWallet.address);
    const providerBalanceBefore = await provider.getBalance(providerAddress);
    const distributorBalanceBefore = await provider.getBalance(distributorAddress);
    const transmittorBalanceBefore = await provider.getBalance(transmittorAddress);
    const generatorBalanceBefore = await provider.getBalance(generatorAddress);

    console.log(`💰 User Balance Before: ${ethers.formatEther(userBalanceBefore)} ETH`);
    console.log(`💰 Provider Balance Before: ${ethers.formatEther(providerBalanceBefore)} ETH`);
    console.log(`💰 Distributor Balance Before: ${ethers.formatEther(distributorBalanceBefore)} ETH`);
    console.log(`💰 Transmittor Balance Before: ${ethers.formatEther(transmittorBalanceBefore)} ETH`);
    console.log(`💰 Generator Balance Before: ${ethers.formatEther(generatorBalanceBefore)} ETH`);

    // ✅ Fetch the user's outstanding bill
    const userFees = await contract.userFees(userWallet.address);
    const totalBill = userFees.totalBill;

    console.log(`📜 Total Bill to Pay: ${ethers.formatEther(totalBill)} ETH`);

    // ✅ Check if the user has enough balance to pay
    if (userBalanceBefore<totalBill) {
        console.error("❌ Insufficient funds to pay the bill.");
        return;
    }

    console.log("🔹 Paying energy fees...");

    // ✅ Pay the energy fees (User signs the transaction)
    const tx = await contract.payEnergyFees({ value: totalBill });
    await tx.wait(); // Wait for transaction confirmation

    console.log("✅ Energy fees paid successfully!");

    console.log("🔹 Fetching ETH balances after transaction...");

    // ✅ Fetch ETH balances after the transaction
    const userBalanceAfter = await provider.getBalance(userWallet.address);
    const providerBalanceAfter = await provider.getBalance(providerAddress);
    const distributorBalanceAfter = await provider.getBalance(distributorAddress);
    const transmittorBalanceAfter = await provider.getBalance(transmittorAddress);
    const generatorBalanceAfter = await provider.getBalance(generatorAddress);

    console.log(`💰 User Balance After: ${ethers.formatEther(userBalanceAfter)} ETH`);
    console.log(`💰 Provider Balance After: ${ethers.formatEther(providerBalanceAfter)} ETH`);
    console.log(`💰 Distributor Balance After: ${ethers.formatEther(distributorBalanceAfter)} ETH`);
    console.log(`💰 Transmittor Balance After: ${ethers.formatEther(transmittorBalanceAfter)} ETH`);
    console.log(`💰 Generator Balance After: ${ethers.formatEther(generatorBalanceAfter)} ETH`);

}

// ✅ Execute the script
main().catch((error) => {
    console.error("❌ Error during transaction:", error.reason || error.message);
    process.exitCode = 1;
});