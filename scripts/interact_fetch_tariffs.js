const hre = require("hardhat");

async function main() {
    const contractAddress = "0x5D42EBdBBa61412295D7b0302d6F50aC449Ddb4F"; // ✅ Replace with deployed contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // ✅ User address

    // ✅ Get deployed contract instance
    const provider = await hre.ethers.getSigner(userAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Fetching all tariffs for user: ${userAddress}`);

    // ✅ Fetch all user data including tariffs
    const [
        peakUsage, stdUsage, offUsage,  // Total Usage
        dist_peakUsage, dist_stdUsage, dist_offUsage, // Distributor Usage
        e1Balance, e2Balance, e3Balance, // Token Balances
        energyFee, distributionFee, transmissionFee, providerFee, totalBill, // Fees
        distributorPeakTariff, distributorStandardTariff, distributorOffpeakTariff, distributorBasicTariff, // Distributor Tariffs
        transmittorPeakTariff, transmittorStandardTariff, transmittorOffpeakTariff, transmittorBasicTariff, // Transmittor Tariffs
        generatorPeakTariff, generatorStandardTariff, generatorOffpeakTariff, generatorBasicTariff // Generator Tariffs
    ] = await contract.viewAllUserData(userAddress);

    // ✅ Display the retrieved tariff data
    console.log(`✅ Retrieved Tariffs for ${userAddress}:`);

    console.log(`📌 **Distributor Tariffs:**`);
    console.log(`   - Peak Tariff: ${distributorPeakTariff} units`);
    console.log(`   - Standard Tariff: ${distributorStandardTariff} units`);
    console.log(`   - Off-Peak Tariff: ${distributorOffpeakTariff} units`);
    console.log(`   - Basic Tariff: ${distributorBasicTariff} units`);

    console.log(`📌 **Transmittor Tariffs:**`);
    console.log(`   - Peak Tariff: ${transmittorPeakTariff} units`);
    console.log(`   - Standard Tariff: ${transmittorStandardTariff} units`);
    console.log(`   - Off-Peak Tariff: ${transmittorOffpeakTariff} units`);
    console.log(`   - Basic Tariff: ${transmittorBasicTariff} units`);

    console.log(`📌 **Generator Tariffs:**`);
    console.log(`   - Peak Tariff: ${generatorPeakTariff} units`);
    console.log(`   - Standard Tariff: ${generatorStandardTariff} units`);
    console.log(`   - Off-Peak Tariff: ${generatorOffpeakTariff} units`);
    console.log(`   - Basic Tariff: ${generatorBasicTariff} units`);

    console.log(`✅ Tariff data retrieval complete.`);
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});



