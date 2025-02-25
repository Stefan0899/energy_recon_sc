const hre = require("hardhat");

async function main() {
    const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";  // ✅ Replace with actual contract address
    const user = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  // ✅ Replace with the user wallet you want to check

    const [provider] = await hre.ethers.getSigners(); // ✅ Gets the first signer
    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress, provider);

    console.log(`\n🔹 Fetching all energy data for: ${user}\n`);

    try {
        // ✅ Get ODO Readings
        const odometers = await contract.getOdometers(user);
        console.log(`📌 ODO Readings:`);
        console.log(`   - Peak ODO: ${odometers[0]}`);
        console.log(`   - Standard ODO: ${odometers[1]}`);
        console.log(`   - Off-Peak ODO: ${odometers[2]}`);

    } catch (error) {
        console.log("❌ Error fetching ODO readings:", error.reason || error.message);
    }

    try {
        // ✅ Get Total Energy Usage
        const usage = await contract.getUsage(user);
        console.log(`\n🔋 Total Energy Usage:`);
        console.log(`   - Peak Usage: ${usage[0]}`);
        console.log(`   - Standard Usage: ${usage[1]}`);
        console.log(`   - Off-Peak Usage: ${usage[2]}`);

    } catch (error) {
        console.log("❌ Error fetching total energy usage:", error.reason || error.message);
    }

    try {
        // ✅ Get Distributor Usage
        const distUsage = await contract.getDistributorUsage(user);
        console.log(`\n📊 Distributor Energy Usage (After Token Deduction):`);
        console.log(`   - Peak Usage: ${distUsage[0]}`);
        console.log(`   - Standard Usage: ${distUsage[1]}`);
        console.log(`   - Off-Peak Usage: ${distUsage[2]}`);

    } catch (error) {
        console.log("❌ Error fetching distributor energy usage:", error.reason || error.message);
    }

    try {
        //Get Total Bill
        const totalBill = await contract.getTotalBill(user);
        console.log(`💰 Total Bill Owed: ${Number(totalBill) / 1e18} ETH`); // ✅ Convert wei to ETH        

    } catch (error) {
        console.log("❌ Error fetching total bill:", error.reason || error.message);
    }

    try {
        // ✅ Get EOM Token Balances
        const balances = await contract.getEOMTokenBalance(user);
        console.log(`\n🔄 EOM Token Balances:`);
        console.log(`   - E1 Tokens: ${balances[0]}`);
        console.log(`   - E2 Tokens: ${balances[1]}`);
        console.log(`   - E3 Tokens: ${balances[2]}`);

    } catch (error) {
        console.log("❌ Error fetching EOM token balances:", error.reason || error.message);
    }

    console.log("\n✅ Data retrieval complete!\n");
}

main().catch((error) => {
    console.error("❌ Unexpected Error:", error);
    process.exitCode = 1;
});
