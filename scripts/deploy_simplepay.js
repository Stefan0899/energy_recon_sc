const hre = require("hardhat");

async function main() {
    console.log("🚀 Deploying SimplePayment contract...");

    const SimplePayment = await hre.ethers.getContractFactory("SimplePayment");
    const simplePayment = await SimplePayment.deploy();

    await simplePayment.waitForDeployment();
    console.log("✅ SimplePayment deployed successfully!");
    console.log("📜 Contract address:", await simplePayment.getAddress());
}

// Run the deployment script
main().catch((error) => {
    console.error("❌ Error during deployment:", error);
    process.exitCode = 1;
});

