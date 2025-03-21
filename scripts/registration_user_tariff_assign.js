require("dotenv").config();
const hre = require("hardhat");

async function main() {
    const contractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // ✅ Replace with deployed contract address
    const provider = new hre.ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    // ✅ Load private keys for each entity from .env
    const distributorWallet = new hre.ethers.Wallet(process.env.DISTRIBUTOR_PRIVATE_KEY, provider);
    const transmittorWallet = new hre.ethers.Wallet(process.env.TRANSMITTOR_PRIVATE_KEY, provider);
    const generatorWallet = new hre.ethers.Wallet(process.env.GENERATOR_PRIVATE_KEY, provider);

    const userAddress = "0x797e3185F817Bd87CdEb14874786b18dbEa93C32"; // ✅ User address

    // ✅ Load the contract instances for each entity
    const distributorContract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, distributorWallet);
    const transmittorContract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, transmittorWallet);
    const generatorContract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, generatorWallet);

    // ✅ Debug Log: Verify Who is Calling the Contract
    console.log(`🔹 Distributor Wallet: ${distributorWallet.address}`);
    console.log(`🔹 Transmittor Wallet: ${transmittorWallet.address}`);
    console.log(`🔹 Generator Wallet: ${generatorWallet.address}`);

    // ✅ Assign Distributor Tariff (Signed by Distributor)
    console.log(`🔹 Assigning distributor tariff to user: ${userAddress}`);
    tx = await distributorContract.assignTariffToUser(userAddress, 1);
    await tx.wait();
    console.log("✅ Distributor Tariff assigned successfully!");

    // ✅ Assign Transmittor Tariff (Signed by Transmittor)

    console.log(`🔹 Assigning transmittor tariff to user: ${userAddress}`);
    tx = await transmittorContract.assignTransmittorTariffToUser(userAddress, 1);
    await tx.wait();
    console.log("✅ Transmittor Tariff assigned successfully!");

    // ✅ Set & Assign Generator Tariff (Signed by Generator)
    console.log(`🔹 Assigning generator tariff to user: ${userAddress}`);
    tx = await generatorContract.assignGeneratorTariffToUser(userAddress, 1);
    await tx.wait();
    console.log("✅ Generator Tariff assigned successfully!");
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});

