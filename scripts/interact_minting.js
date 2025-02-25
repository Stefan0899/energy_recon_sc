const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x610178dA211FEF7D417bC0e6FeD39F05609AD788"; // Replace with actual factory address
    const recipient = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // Replace with actual user address
    const amount = hre.ethers.parseEther("100");

    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    console.log(`Minting 80 E1 tokens to ${recipient}...`);
    await factory.mintE1(recipient, amount);
    console.log("✅ Minted E1 tokens");

    console.log(`Minting 90 E2 tokens to ${recipient}...`);
    await factory.mintE2(recipient, hre.ethers.parseEther("50"));
    console.log("✅ Minted E2 tokens");

    console.log(`Minting 65 E3 tokens to ${recipient}...`);
    await factory.mintE3(recipient, hre.ethers.parseEther("75"));
    console.log("✅ Minted E3 tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
