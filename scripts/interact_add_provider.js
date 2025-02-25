const hre = require("hardhat");

async function main() {
    const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";
    const providerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // Replace with actual provider address

    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress);

    console.log(`Adding provider: ${providerAddress}`);
    await contract.addProvider(providerAddress);
    console.log("✅ Provider added successfully");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
