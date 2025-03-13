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
    console.log("Ep Token deployed at:", await factory.tokenEp());
    console.log("Es Token deployed at:", await factory.tokenEs());
    console.log("Eo Token deployed at:", await factory.tokenEo());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

