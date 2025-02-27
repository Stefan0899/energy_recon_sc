const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
    const contractAddress = "0x5D42EBdBBa61412295D7b0302d6F50aC449Ddb4F"; // Replace with your deployed contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // Replace with the user who will pay the fees

    // ✅ Get the contract instance
    const signer = await ethers.getSigner(userAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, signer);

    // ✅ Fetch assigned addresses
    const providerAddress = await contract.userProvider(userAddress);
    const distributorAddress = await contract.userDistributor(userAddress);
    const transmittorAddress = await contract.userTransmittor(userAddress);

    console.log("🔹 Fetching ETH balances before transaction...");

    // ✅ Fetch ETH balances before the transaction
    const userBalanceBefore = await ethers.provider.getBalance(userAddress);
    const providerBalanceBefore = await ethers.provider.getBalance(providerAddress);
    const distributorBalanceBefore = await ethers.provider.getBalance(distributorAddress);
    const transmittorBalanceBefore = await ethers.provider.getBalance(transmittorAddress);

    console.log(`💰 User Balance Before: ${ethers.formatEther(userBalanceBefore)} ETH`);
    console.log(`💰 Provider Balance Before: ${ethers.formatEther(providerBalanceBefore)} ETH`);
    console.log(`💰 Distributor Balance Before: ${ethers.formatEther(distributorBalanceBefore)} ETH`);
    console.log(`💰 Transmittor Balance Before: ${ethers.formatEther(transmittorBalanceBefore)} ETH`);

    // ✅ Fetch the user's outstanding bill
    const userFees = await contract.userFees(userAddress);
    const totalBill = userFees.totalBill;

    console.log(`📜 Total Bill to Pay: ${ethers.formatEther(totalBill)} ETH`);

    console.log("🔹 Paying energy fees...");
    
    // ✅ Pay the energy fees
    const tx = await contract.payEnergyFees({ value: totalBill });
    await tx.wait(); // Wait for transaction confirmation

    console.log("✅ Energy fees paid successfully!");

    console.log("🔹 Fetching ETH balances after transaction...");

    // ✅ Fetch ETH balances after the transaction
    const userBalanceAfter = await ethers.provider.getBalance(userAddress);
    const providerBalanceAfter = await ethers.provider.getBalance(providerAddress);
    const distributorBalanceAfter = await ethers.provider.getBalance(distributorAddress);
    const transmittorBalanceAfter = await ethers.provider.getBalance(transmittorAddress);

    console.log(`💰 User Balance After: ${ethers.formatEther(userBalanceAfter)} ETH`);
    console.log(`💰 Provider Balance After: ${ethers.formatEther(providerBalanceAfter)} ETH`);
    console.log(`💰 Distributor Balance After: ${ethers.formatEther(distributorBalanceAfter)} ETH`);
    console.log(`💰 Transmittor Balance After: ${ethers.formatEther(transmittorBalanceAfter)} ETH`);
}

// ✅ Execute the script
main().catch((error) => {
    console.error("❌ Error during transaction:", error.reason || error.message);
    process.exitCode = 1;
});
