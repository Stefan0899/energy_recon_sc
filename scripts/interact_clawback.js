const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x9d4454B023096f34B160D6B654540c56A1F81688"; // Replace with actual factory address
    const user = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Replace with user wallet address
    const amount = hre.ethers.parseEther("10");

    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    console.log(`Clawing back 10 E1 tokens from ${user}...`);
    await factory.clawbackE1(user, amount);
    console.log("✅ Clawed back E1 tokens");

    console.log(`Clawing back 5 E2 tokens from ${user}...`);
    await factory.clawbackE2(user, hre.ethers.parseEther("5"));
    console.log("✅ Clawed back E2 tokens");

    console.log(`Clawing back 8 E3 tokens from ${user}...`);
    await factory.clawbackE3(user, hre.ethers.parseEther("8"));
    console.log("✅ Clawed back E3 tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
