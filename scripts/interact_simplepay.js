const { ethers } = require("hardhat");

async function main() {
    const contractAddress = "0x4A679253410272dd5232B3Ff7cF5dbB88f295319"; // Replace with actual address
    const user1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // User1
    const user2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"; // User2

    const ContractFactory = await ethers.getContractFactory("SimplePayment");
    const contract = await ContractFactory.attach(contractAddress);

    console.log("\n🛠 Interacting with contract at:", contractAddress);

    // 🔹 Step 1: Provider updates ODOs for User1
    console.log("\n🚀 Provider updating odometer readings for User1...");
    let tx = await contract.updateOdometersAndCalculateBill(user1, 50000300, 60000500, 70000700);
    await tx.wait();
    console.log("✅ ODO values updated and bill calculated for User1!");

    // 🔹 Step 2: Provider updates ODOs for User2
    console.log("\n🚀 Provider updating odometer readings for User2...");
    tx = await contract.updateOdometersAndCalculateBill(user2, 50000600, 60000750, 70000910);
    await tx.wait();
    console.log("✅ ODO values updated and bill calculated for User2!");

    // 🔹 Step 3: User1 checks their bill
    console.log("\n🔍 User1 checking bill...");
    let user1Bill = await contract.connect(await ethers.getSigner(user1)).getBillAmount();
    console.log(`💰 User1 owes: ${ethers.formatEther(user1Bill)} ETH`);

    // 🔹 Step 4: User2 checks their bill
    console.log("\n🔍 User2 checking bill...");
    let user2Bill = await contract.connect(await ethers.getSigner(user2)).getBillAmount();
    console.log(`💰 User2 owes: ${ethers.formatEther(user2Bill)} ETH`);

    // 🔹 Step 5: User1 pays their bill (ETH goes to Provider)
    console.log("\n💸 User1 paying bill...");
    tx = await contract.connect(await ethers.getSigner(user1)).payBill({ value: user1Bill });
    await tx.wait();
    console.log("✅ User1 payment successful! Provider received ETH.");

    // 🔹 Step 6: User2 pays their bill (ETH goes to Provider)
    console.log("\n💸 User2 paying bill...");
    tx = await contract.connect(await ethers.getSigner(user2)).payBill({ value: user2Bill });
    await tx.wait();
    console.log("✅ User2 payment successful! Provider received ETH.");
}

// Run the script
main().catch((error) => {
    console.error("❌ Error:", error);
    process.exit(1);
});

