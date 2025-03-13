const hre = require("hardhat");

async function main() {
    const sender = "0x57D5d45C25C7185008aE9E8Aa0C951092AF64588"; // Your MetaMask sender address
    const recipient = "0xba539dF3129699C57148AF13E1027e7673bcC36C"; // Replace with recipient's wallet address
    const amount = hre.ethers.parseEther("2"); // Amount of ETH to send (0.1 ETH)

    // Get the sender's signer (wallet)
    const [deployer] = await hre.ethers.getSigners(sender);

    console.log(`🔹 Sending ${hre.ethers.formatEther(amount)} SepoliaETH from ${sender} to ${recipient}...`);

    // Send the ETH transaction
    const tx = await deployer.sendTransaction({
        to: recipient,
        value: amount, // Amount in wei
    });

    console.log("✅ Transaction sent! Waiting for confirmation...");
    await tx.wait();

    console.log(`✅ Transaction successful! Hash: ${tx.hash}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
