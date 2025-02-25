const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F"; // Replace with actual address

    // Attach to deployed contract
    const ContractFactory = await ethers.getContractFactory("EnergyUsageTracker");
    const contract = await ContractFactory.attach(contractAddress);

    console.log("\n🛠 Interacting with contract at:", contractAddress);

    // 🔹 Step 1: First time updating odometers (No Usage Calculated)
    console.log("\n🚀 Setting initial ODO values...");
    let tx = await contract.updateOdometers(50000000, 60000000, 70000000);
    await tx.wait();
    console.log("✅ ODO values set for the first time!");

    // Retrieve ODO values
    let [peakODO, stdODO, offODO] = await contract.getOdometers();
    console.log(`📊 Stored ODOs: PEAKODO=${peakODO}, STDODO=${stdODO}, OFFODO=${offODO}`);

    // 🔹 Step 2: Get Usage (Should be 0 since it's the first entry)
    let [peakUsage, stdUsage, offUsage] = await contract.getUsage();
    console.log(`📉 Initial Usage: PEAKUSAGE=${peakUsage}, STDUSAGE=${stdUsage}, OFFUSAGE=${offUsage}`);

    // 🔹 Step 3: Second update (Calculates usage)
    console.log("\n🚀 Updating ODO values again...");
    tx = await contract.updateOdometers(50000050, 60000080, 70000100);
    await tx.wait();
    console.log("✅ ODO values updated!");

    // Retrieve new ODO values
    [peakODO, stdODO, offODO] = await contract.getOdometers();
    console.log(`📊 New Stored ODOs: PEAKODO=${peakODO}, STDODO=${stdODO}, OFFODO=${offODO}`);

    // 🔹 Step 4: Get Updated Usage (Now usage should be calculated)
    [peakUsage, stdUsage, offUsage] = await contract.getUsage();
    console.log(`📉 New Usage: PEAKUSAGE=${peakUsage}, STDUSAGE=${stdUsage}, OFFUSAGE=${offUsage}`);
}

// Run the script
main().catch((error) => {
    console.error("❌ Error:", error);
    process.exit(1);
});
