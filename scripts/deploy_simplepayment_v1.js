const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deployer Address:", deployer.address);

    const SimplePayment_v1 = await hre.ethers.getContractFactory("Energy_Recon");
    const contract = await SimplePayment_v1.deploy();

    await contract.waitForDeployment();
    console.log("Contract Adress:", await contract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
