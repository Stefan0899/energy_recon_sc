const hre = require("hardhat");

async function main() {
    const contractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // ✅ Replace with deployed contract address
    const userAddress = "0x5Ab76a41eeC00851002C861E3B3a9CFF134ca526"; // ✅ User whose data we are viewing

    // ✅ Get deployed contract instance
    const provider = new ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);
    const contract = await ethers.getContractAt("Energy_Recon", contractAddress, provider);

    console.log(`🔹 Fetching all user data for: ${userAddress}`);

    try {
        // ✅ Call viewAllUserData function
        const userData = await contract.viewAllUserData(userAddress);

        // ✅ Extract results
        const [
            peakUsage, stdUsage, offUsage,
            gen_peakUsage, gen_stdUsage, gen_offUsage,
            epBalance, esBalance, eoBalance,
            distributionFee, transmissionFee, generatorFee, providerFee, totalBill,
            distributorPeakTariff, distributorStandardTariff, distributorOffpeakTariff, distributorBasicTariff,
            transmittorPeakTariff, transmittorStandardTariff, transmittorOffpeakTariff, transmittorBasicTariff,
            generatorPeakTariff, generatorStandardTariff, generatorOffpeakTariff, generatorBasicTariff,
            peakODO, stdODO, offODO
        ] = userData;

        // ✅ Display Results
        console.log("\n📌 Energy Usage:");
        console.log(`   - Peak Usage: ${peakUsage}`);
        console.log(`   - Standard Usage: ${stdUsage}`);
        console.log(`   - Off-Peak Usage: ${offUsage}`);

        console.log("\n🔋 Distributor Energy Usage:");
        console.log(`   - Peak Usage: ${gen_peakUsage}`);
        console.log(`   - Standard Usage: ${gen_stdUsage}`);
        console.log(`   - Off-Peak Usage: ${gen_offUsage}`);

        console.log("\n💰 End-of-Month Token Balances:");
        console.log(`   - E1 Tokens: ${epBalance}`);
        console.log(`   - E2 Tokens: ${esBalance}`);
        console.log(`   - E3 Tokens: ${eoBalance}`);

        console.log("\n💵 Fees:");
        console.log(`   - Distribution Fee: ${Number(distributionFee) / 1e18} ETH`);
        console.log(`   - Transmission Fee: ${Number(transmissionFee) / 1e18} ETH`);
        console.log(`   - Generator Fee: ${Number(generatorFee) / 1e18} ETH`);
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

        console.log("\n🔋 ODOs:");
        console.log(`   - Peak ODO: ${peakODO}`);
        console.log(`   - Standard ODO: ${stdODO}`);
        console.log(`   - Off-Peak ODO: ${offODO}`);

    } catch (error) {
        console.log("❌ Error fetching user data:", error.reason || error.message);
    }
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});
