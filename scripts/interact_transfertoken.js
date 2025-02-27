const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x045857BDEAE7C1c7252d611eB24eB55564198b4C"; // Replace with actual factory contract address
    const sender = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Replace with sender's wallet address
    const recipient = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788"; // Replace with recipient's wallet address
    const amount = hre.ethers.parseEther("85"); // Amount to transfer

    // Get the factory contract
    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    // Get deployed EnergyTokens
    const tokenE1 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE1());
    const tokenE2 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE2());
    const tokenE3 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE3());

    // Transfer 10 tokens of each type
    console.log(`Transferring 10 E1 tokens from ${sender} to ${recipient}...`);
    await tokenE1.transfer(recipient, amount);
    console.log("✅ E1 transfer successful");

    console.log(`Transferring 5 E2 tokens from ${sender} to ${recipient}...`);
    await tokenE2.transfer(recipient, hre.ethers.parseEther("35"));
    console.log("✅ E2 transfer successful");

    console.log(`Transferring 8 E3 tokens from ${sender} to ${recipient}...`);
    await tokenE3.transfer(recipient, hre.ethers.parseEther("71"));
    console.log("✅ E3 transfer successful");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
