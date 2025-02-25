const hre = require("hardhat");

async function main() {
    console.log("Deploying the contract...");

    // Get the contract factory
    const MyContract = await hre.ethers.getContractFactory("MyContract");

    // Deploy with an initial message
    const myContract = await MyContract.deploy("Hello, Ethereum!");

    // Wait for deployment confirmation
    await myContract.waitForDeployment();

    // Get the deployed contract address
    const contractAddress = await myContract.getAddress();
    
    console.log("Contract deployed successfully!");
    console.log("Contract address:", contractAddress);
}

// Run the deployment script
main().catch((error) => {
    console.error("Error during deployment:", error);
    process.exitCode = 1;
});

