const hre = require("hardhat");

async function main() {
    const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";  // ✅ Replace with actual deployed contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  // ✅ Replace with the user's address

    const provider = await hre.ethers.getSigner("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"); // ✅ Replace with an approved provider address
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Setting tariffs for: ${userAddress}`);

    // ✅ Define tariff values (set according to your business logic)
    const peakTariff = 200;  // 2 ETH per unit
    const standardTariff = 100;  // 1 ETH per unit
    const offpeakTariff = 500;  // 0.5 ETH per unit
    const basicTariff = 100;  // 0.2 ETH flat fee

    // ✅ Call the function to set tariffs
    const tx = await contract.setUserTariffs(userAddress, peakTariff, standardTariff, offpeakTariff, basicTariff);
    await tx.wait();

    console.log(`✅ Tariffs set successfully for user: ${userAddress}`);
    console.log(`   - Peak Tariff: ${peakTariff} ETH`);
    console.log(`   - Standard Tariff: ${standardTariff} ETH`);
    console.log(`   - Off-Peak Tariff: ${offpeakTariff} ETH`);
    console.log(`   - Basic Tariff: ${basicTariff} ETH`);
}

main().catch((error) => {
    console.error("❌ Error setting tariffs:", error.reason || error.message);
    process.exitCode = 1;
});
