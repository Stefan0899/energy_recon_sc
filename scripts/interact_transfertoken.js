const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x15381B00823186EAA183a0395aF91CeF90aB5905"; // Replace with actual factory contract address
    const sender = "0x57D5d45C25C7185008aE9E8Aa0C951092AF64588"; // Replace with sender's wallet address
    const recipient = "0x797e3185F817Bd87CdEb14874786b18dbEa93C32"; // Replace with recipient's wallet address
    const amount = hre.ethers.parseEther("12"); // Amount to transfer

    // Get the factory contract
    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    // Get deployed EnergyTokens
    const tokenE1 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenEp());
    const tokenE2 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenEs());
    const tokenE3 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenEo());

    // Transfer 10 tokens of each type
    console.log(`Transferring 12 Ep tokens from ${sender} to ${recipient}...`);
    await tokenE1.transfer(recipient, amount);
    console.log("✅ Ep transfer successful");

    console.log(`Transferring 7 Es tokens from ${sender} to ${recipient}...`);
    await tokenE2.transfer(recipient, hre.ethers.parseEther("7"));
    console.log("✅ Es transfer successful");

    console.log(`Transferring 9 Eo tokens from ${sender} to ${recipient}...`);
    await tokenE3.transfer(recipient, hre.ethers.parseEther("9"));
    console.log("✅ Eo transfer successful");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
