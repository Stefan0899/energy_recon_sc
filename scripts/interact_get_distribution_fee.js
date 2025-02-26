const hre = require("hardhat");

async function main() {
    const contractAddress = "0xc0F115A19107322cFBf1cDBC7ea011C19EbDB4F8"; // ✅ Replace with deployed contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // ✅ User address

    // ✅ Get deployed contract instance
    const provider = await hre.ethers.getSigner(userAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Fetching distribution and transmission fees for user: ${userAddress}`);

    try {
        // ✅ Fetch the distribution fee
        const Fees = await contract.getTransmissionFee(userAddress);
        console.log(`💰 Energy Fee Owed: ${Number(Fees[0]) / 1e16} ETH`);
        console.log(`💰 Distribution Fee Owed: ${Number(Fees[1]) / 1e16} ETH`);
        console.log(`💰 Transmission Fee Owed: ${Number(Fees[2]) / 1e16} ETH`);

    } catch (error) {
        console.log("❌ Error fetching fees:", error.reason || error.message);
    }
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});





