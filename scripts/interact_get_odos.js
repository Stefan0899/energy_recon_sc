const hre = require("hardhat");

async function main() {
    const contractAddress = "0xB0D4afd8879eD9F52b28595d31B441D079B2Ca07";  // ✅ Replace with deployed contract address
    const user = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65";  // ✅ Replace with a test user wallet

    const [provider] = await hre.ethers.getSigners(); // ✅ Retrieves the first available Hardhat signer
    const contract = await hre.ethers.getContractAt("SimplePayment_v1", contractAddress, provider);

    console.log(`🔹 Fetching ODO readings for: ${user}`);

    const odometers = await contract.getOdometers(user);
    console.log(`📌 ODO Readings: Peak=${odometers[0]}, Standard=${odometers[1]}, Off-Peak=${odometers[2]}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

