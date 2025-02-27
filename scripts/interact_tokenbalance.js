const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x045857BDEAE7C1c7252d611eB24eB55564198b4C"; // Replace with actual factory address
    const user = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788"; // Replace with the wallet address to check balance

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
