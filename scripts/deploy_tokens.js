const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deployer Address:", deployer.address);

    // Deploy EnergyTokenFactory
    const EnergyTokenFactory = await hre.ethers.getContractFactory("EnergyTokenFactory");
    const factory = await EnergyTokenFactory.deploy(deployer.address);

    await factory.waitForDeployment(); // Ensures deployment completes

    // Explicitly fetch the contract address
    const factoryAddress = await factory.getAddress();

    console.log("FactoryAddress:", factoryAddress);
    console.log("E1 Token deployed at:", await factory.tokenE1());
    console.log("E2 Token deployed at:", await factory.tokenE2());
    console.log("E3 Token deployed at:", await factory.tokenE3());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

