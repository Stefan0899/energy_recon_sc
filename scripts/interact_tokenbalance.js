const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x610178dA211FEF7D417bC0e6FeD39F05609AD788"; // Replace with actual factory address
    const user = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // Replace with the wallet address to check balance

    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);
    
    const tokenE1 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE1());
    const tokenE2 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE2());
    const tokenE3 = await hre.ethers.getContractAt("EnergyToken", await factory.tokenE3());

    const balanceE1 = await tokenE1.balanceOf(user);
    const balanceE2 = await tokenE2.balanceOf(user);
    const balanceE3 = await tokenE3.balanceOf(user);

    console.log(`E1 Balance: ${hre.ethers.formatEther(balanceE1)} Tokens`);
    console.log(`E2 Balance: ${hre.ethers.formatEther(balanceE2)} Tokens`);
    console.log(`E3 Balance: ${hre.ethers.formatEther(balanceE3)} Tokens`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
