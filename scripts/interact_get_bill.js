const hre = require("hardhat");

async function main() {
    const contractAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";  // ✅ Replace with actual contract address
    const userAddress = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788";  // ✅ Replace with user address

    const [signer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress, signer);

    console.log(`🔹 Fetching bill for user: ${userAddress}`);

    try {
        // ✅ Call getBillInfo() instead of accessing mapping directly
        const bill = await contract.getBillInfo(userAddress);
        console.log(`💰 Outstanding Bill: ${hre.ethers.formatEther(bill[0])} ETH`);
    } catch (error) {
        console.log("❌ No bill found for this user.");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});




