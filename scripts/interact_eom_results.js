const hre = require("hardhat");

async function main() {
    const contractAddress = "0x2Dd78Fd9B8F40659Af32eF98555B8b31bC97A351"; // ✅ Replace with deployed contract address
    const userAddress = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788"; // ✅ User whose data we are viewing

    // ✅ Get deployed contract instance
    const provider = await hre.ethers.getSigner(userAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Fetching all user data for: ${userAddress}`);

    try {
        // ✅ Call viewAllUserData function
        const userData = await contract.viewAllUserData(userAddress);

        // ✅ Extract results
        const [
            peakUsage, stdUsage, offUsage,
            dist_peakUsage, dist_stdUsage, dist_offUsage,
            e1Balance, e2Balance, e3Balance,
            energyFee, distributionFee, transmissionFee, providerFee, totalBill,
            distributorPeakTariff, distributorStandardTariff, distributorOffpeakTariff, distributorBasicTariff,
            transmittorPeakTariff, transmittorStandardTariff, transmittorOffpeakTariff, transmittorBasicTariff,
            generatorPeakTariff, generatorStandardTariff, generatorOffpeakTariff, generatorBasicTariff
        ] = userData;

        // ✅ Display Results
        console.log("\n📌 Energy Usage:");
        console.log(`   - Peak Usage: ${peakUsage}`);
        console.log(`   - Standard Usage: ${stdUsage}`);
        console.log(`   - Off-Peak Usage: ${offUsage}`);

        console.log("\n🔋 Distributor Energy Usage:");
        console.log(`   - Peak Usage: ${dist_peakUsage}`);
        console.log(`   - Standard Usage: ${dist_stdUsage}`);
        console.log(`   - Off-Peak Usage: ${dist_offUsage}`);

        console.log("\n💰 End-of-Month Token Balances:");
        console.log(`   - E1 Tokens: ${e1Balance}`);
        console.log(`   - E2 Tokens: ${e2Balance}`);
        console.log(`   - E3 Tokens: ${e3Balance}`);

        console.log("\n💵 Fees:");
        console.log(`   - Energy Fee: ${Number(energyFee) / 1e18} ETH`);
        console.log(`   - Distribution Fee: ${Number(distributionFee) / 1e18} ETH`);
        console.log(`   - Transmission Fee: ${Number(transmissionFee) / 1e18} ETH`);
        console.log(`   - Provider Fee: ${Number(providerFee) / 1e18} ETH`);
        console.log(`   - Total Bill: ${Number(totalBill) / 1e18} ETH`);

        console.log("\n🏭 Distributor Tariffs:");
        console.log(`   - Peak Tariff: ${distributorPeakTariff}`);
        console.log(`   - Standard Tariff: ${distributorStandardTariff}`);
        console.log(`   - Off-Peak Tariff: ${distributorOffpeakTariff}`);
        console.log(`   - Basic Tariff: ${distributorBasicTariff}`);

        console.log("\n⚡ Transmittor Tariffs:");
        console.log(`   - Peak Tariff: ${transmittorPeakTariff}`);
        console.log(`   - Standard Tariff: ${transmittorStandardTariff}`);
        console.log(`   - Off-Peak Tariff: ${transmittorOffpeakTariff}`);
        console.log(`   - Basic Tariff: ${transmittorBasicTariff}`);

        console.log("\n🔋 Generator Tariffs:");
        console.log(`   - Peak Tariff: ${generatorPeakTariff}`);
        console.log(`   - Standard Tariff: ${generatorStandardTariff}`);
        console.log(`   - Off-Peak Tariff: ${generatorOffpeakTariff}`);
        console.log(`   - Basic Tariff: ${generatorBasicTariff}`);

    } catch (error) {
        console.log("❌ Error fetching user data:", error.reason || error.message);
    }
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});
