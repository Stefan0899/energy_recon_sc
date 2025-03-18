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

    // Connect each wallet to the contract
    const ownerContract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, ownerWallet);

    // ✅ Add Provider (Signed by Owner)
    console.log(`🔹 Adding new provider: ${providerWallet.address}`);
    let tx = await ownerContract.addProvider(providerWallet.address);
    await tx.wait();
    console.log(`✅ Provider added successfully: ${providerWallet.address}`);

    // ✅ Add Distributor (Signed by Owner)
    console.log(`🔹 Adding new distributor: ${distributorWallet.address}`);
    tx = await ownerContract.addDistributor(distributorWallet.address);
    await tx.wait();
    console.log(`✅ Distributor added successfully: ${distributorWallet.address}`);

    // ✅ Add Transmittor (Signed by Owner)
    console.log(`🔹 Adding new transmittor: ${transmittorWallet.address}`);
    tx = await ownerContract.addTransmittor(transmittorWallet.address);
    await tx.wait();
    console.log(`✅ Transmittor added successfully: ${transmittorWallet.address}`);

    // ✅ Add Generator (Signed by Owner)
    console.log(`🔹 Adding new generator: ${generatorWallet.address}`);
    tx = await ownerContract.addGenerator(generatorWallet.address);
    await tx.wait();
    console.log(`✅ Generator added successfully: ${generatorWallet.address}`);

}

// Execute the script
main().catch((error) => {
    console.error("❌ Error during registration:", error.reason || error.message);
    process.exitCode = 1;
});
