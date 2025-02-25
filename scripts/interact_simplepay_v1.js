const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x851356ae760d987E095750cCeb3bC6014560891C"; // Replace with actual address
    const providerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // Provider1
    const user1Address = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // User1
    const user2Address = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"; // User2

    const ContractFactory = await ethers.getContractFactory("SimplePayment");
    const contract = await ContractFactory.attach(contractAddress);

    console.log("\n🛠 Interacting with contract at:", contractAddress);

    // 🔹 Step 1: Provider updates ODOs for User1
    console.log("\n🚀 Provider updating odometer readings for User1...");
    let tx = await contract.updateOdometersAndCalculateBill(user1Address, 50000710, 60000890, 70000996);
    await tx.wait();
    console.log("✅ ODO values updated and bill calculated for User1!");

    // 🔹 Step 2: Provider updates ODOs for User2
    console.log("\n🚀 Provider updating odometer readings for User2...");
    tx = await contract.updateOdometersAndCalculateBill(user2Address, 50000812, 60000953, 70001060);
    await tx.wait();
    console.log("✅ ODO values updated and bill calculated for User2!");

    // 🔹 Step 4: Print Usage for Each User
    console.log("\n⚡ Checking Energy Usage...");
    let [user1PeakUsage, user1StdUsage, user1OffUsage] = await contract.connect(await ethers.getSigner(user1Address)).getUsage();
    console.log(`🔹 User1 Usage: PEAK=${user1PeakUsage}, STD=${user1StdUsage}, OFF=${user1OffUsage}`);

    let [user2PeakUsage, user2StdUsage, user2OffUsage] = await contract.connect(await ethers.getSigner(user2Address)).getUsage();
    console.log(`🔹 User2 Usage: PEAK=${user2PeakUsage}, STD=${user2StdUsage}, OFF=${user2OffUsage}`);

    // 🔹 Step 5: Print Bill Amounts for Each User
    console.log("\n🔍 Checking Bill Amounts...");
    let user1Bill = await contract.connect(await ethers.getSigner(user1Address)).getBillAmount();
    console.log(`💰 User1 owes: ${ethers.formatEther(user1Bill)} ETH`);

    let user2Bill = await contract.connect(await ethers.getSigner(user2Address)).getBillAmount();
    console.log(`💰 User2 owes: ${ethers.formatEther(user2Bill)} ETH`);

    // 🔹 Step 6: User1 pays their bill (ETH goes to Provider)
    console.log("\n💸 User1 paying bill...");
    tx = await contract.connect(await ethers.getSigner(user1Address)).payBill({ value: user1Bill });
    await tx.wait();
    console.log("✅ User1 payment successful! Provider received ETH.");

    // 🔹 Step 7: User2 pays their bill (ETH goes to Provider)
    console.log("\n💸 User2 paying bill...");
    tx = await contract.connect(await ethers.getSigner(user2Address)).payBill({ value: user2Bill });
    await tx.wait();
    console.log("✅ User2 payment successful! Provider received ETH.");
}

// Run the script
main().catch((error) => {
    console.error("❌ Error:", error);
    process.exit(1);
});

