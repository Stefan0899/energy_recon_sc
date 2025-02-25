const hre = require("hardhat");

async function main() {
    console.log("Deploying EnergyUsageTracker contract...");

    const EnergyUsageTracker = await hre.ethers.getContractFactory("EnergyUsageTracker");
    const energyUsageTracker = await EnergyUsageTracker.deploy();

    await energyUsageTracker.waitForDeployment();
    console.log("EnergyUsageTracker deployed successfully!");
    console.log("Contract address:", await energyUsageTracker.getAddress());
}

// Run the deployment script
main().catch((error) => {
    console.error("Error during deployment:", error);
    process.exitCode = 1;
});
