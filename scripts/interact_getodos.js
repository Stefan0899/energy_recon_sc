const hre = require("hardhat");

async function main() {
    const contractAddress = "0xFD471836031dc5108809D173A067e8486B9047A3";  // ✅ Replace with actual contract address
    const userAddress = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788";  // ✅ Replace with user address

    const [signer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress, signer);

    console.log(`🔹 Fetching odometer readings, usage & bill for user: ${userAddress}`);

    // ✅ Get odometer readings
    try {
        const odometers = await contract.getOdometers(userAddress);
        console.log(`📌 Current Odometers for ${userAddress}:`);
        console.log(`   - Peak: ${odometers[0]}`);
        console.log(`   - Standard: ${odometers[1]}`);
        console.log(`   - Off-Peak: ${odometers[2]}`);
    } catch (error) {
        console.log("❌ Error fetching odometer readings. Ensure the user has ODO readings.");
    }

    // ✅ Get energy usage
    try {
        const usage = await contract.getUsage(userAddress);
        console.log(`🔋 Energy Usage:`);
        console.log(`   - Peak Usage: ${usage[0]} kWh`);
        console.log(`   - Standard Usage: ${usage[1]} kWh`);
        console.log(`   - Off-Peak Usage: ${usage[2]} kWh`);
    } catch (error) {
        console.log("❌ Error fetching energy usage. Ensure ODO readings were updated.");
    }

    // ✅ Fetch and print bill
    try {
        const bill = await contract.getBillInfo(userAddress);
        console.log(`💰 Outstanding Bill: ${hre.ethers.formatEther(bill[0])} ETH`);
    } catch (error) {
        console.log("❌ Error fetching bill. Ensure the user has an assigned bill.");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});


