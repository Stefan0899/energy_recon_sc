require("dotenv").config();
const hre = require("hardhat");

async function main() {
    const contractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // Replace with actual contract address
    const provider = new hre.ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    // Load private keys for each account from .env
    const ownerWallet = new hre.ethers.Wallet(process.env.OWNER_PRIVATE_KEY, provider);
    const providerWallet = new hre.ethers.Wallet(process.env.PROVIDER_PRIVATE_KEY, provider);
    const distributorWallet = new hre.ethers.Wallet(process.env.DISTRIBUTOR_PRIVATE_KEY, provider);
    const transmittorWallet = new hre.ethers.Wallet(process.env.TRANSMITTOR_PRIVATE_KEY, provider);
    const generatorWallet = new hre.ethers.Wallet(process.env.GENERATOR_PRIVATE_KEY, provider);

    const userAddress = "0x797e3185F817Bd87CdEb14874786b18dbEa93C32"; // Replace with actual user

    // Connect each wallet to the contract
    const ownerContract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, ownerWallet);

    // ✅ Assign Provider (Signed by Provider)
    console.log(`🔹 Assigning provider: ${providerWallet.address}`);
    tx = await ownerContract.assignProviderToUser(userAddress);
    await tx.wait();
    console.log(`✅ Provider assigned: ${providerWallet.address}`);

    // ✅ Assign Distributor (Signed by Distributor)
    console.log(`🔹 Assigning distributor: ${distributorWallet.address}`);
    tx = await ownerContract.assignDistributorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Distributor assigned: ${distributorWallet.address}`);

    // ✅ Assign Transmittor (Signed by Transmittor)
    console.log(`🔹 Assigning transmittor: ${transmittorWallet.address}`);
    tx = await ownerContract.assignTransmittorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Transmittor assigned: ${transmittorWallet.address}`);

    // ✅ Assign Generator (Signed by Generator)
    console.log(`🔹 Assigning generator: ${generatorWallet.address}`);
    tx = await ownerContract.assignGeneratorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Generator assigned: ${generatorWallet.address}`);
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error during registration:", error.reason || error.message);
    process.exitCode = 1;
});