const hre = require("hardhat");

async function main() {
    const contractAddress = "0x2bdCC0de6bE1f7D2ee689a0342D76F52E8EFABa3"; // ✅ Replace with correct contract address
    const providerAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // ✅ Replace with provider's address
    const userAddress = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"; // ✅ Replace with user's wallet address

    const provider = await hre.ethers.getSigner(providerAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress, provider);

    console.log(`🔹 Provider (${provider.address}) updating odometers for user: ${userAddress}`);

    // ✅ Update odometers and generate bill
    const tx = await contract.updateOdometersAndCalculateBill(
        userAddress,
        1400, // Peak ODO
        1500, // Standard ODO
        1600  // Off-peak ODO
    );
    await tx.wait();
    console.log("✅ Odometers updated and bill calculated!");

    // ✅ Fetch and print bill if it exists
    console.log("🔹 Fetching user's bill...");
    const billAmount = await contract.getBillAmount();
    console.log(`💰 Outstanding Bill: ${hre.ethers.formatEther(billAmount)} ETH`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});


