const hre = require("hardhat");

async function main() {
    const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";  // ✅ Replace with actual contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  // ✅ Replace with the user's address

    const [provider] = await hre.ethers.getSigners(); // ✅ Gets the first signer
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Fetching tariffs for: ${userAddress}`);

    try {
        // ✅ Fetch tariffs
        const tariffs = await contract.getUserTariffs(userAddress);

        // ✅ Convert BigInt to Number before division
        console.log(`📊 Tariffs for ${userAddress}:`);
        console.log(`   - Peak Tariff: ${tariffs[0]} ETH`);
        console.log(`   - Standard Tariff: ${tariffs[1]} ETH`);
        console.log(`   - Off-Peak Tariff: ${tariffs[2]} ETH`);
        console.log(`   - Basic Tariff: ${tariffs[3]} ETH`);
    } catch (error) {
        console.log("❌ Error fetching tariffs:", error.reason || error.message);
    }

    console.log("\n✅ Data retrieval complete!");
}

main().catch((error) => {
    console.error("❌ Unexpected Error:", error);
    process.exitCode = 1;
});


