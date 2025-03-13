require("dotenv").config();
const hre = require("hardhat");

async function main() {
    const contractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // ✅ Replace with deployed contract address
    const provider = new ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    // ✅ Load Provider Wallet from .env
    const providerWallet = new ethers.Wallet(process.env.PROVIDER_PRIVATE_KEY, provider);

    // ✅ Connect the contract with the Provider Wallet
    const contract = await hre.ethers.getContractAt("Energy_Recon", contractAddress, providerWallet);

    // ✅ Define User & Distributor Addresses
    const user = "0x5Ab76a41eeC00851002C861E3B3a9CFF134ca526"; // ✅ User Wallet Address
    const distributor = "0x57D5d45C25C7185008aE9E8Aa0C951092AF64588"; // ✅ Assigned Distributor

    console.log(`🔹 Provider (${providerWallet.address}) updating ODO readings for: ${user}`);

    // ✅ Define ODO readings
    const peakODO = 14000; // New Peak ODO reading
    const stdODO = 25000; // New Standard ODO reading
    const offODO = 13000; // New Off-peak ODO reading

    // ✅ Replace with deployed token addresses
    const EpToken = "0x80Aa523191C962211197D1AaC450cF5f9f5Eb874";
    const EsToken = "0xa7db5E6Bb54f323EFD3b99ABf84EDC72046bfD86";
    const EoToken = "0x0E46342329F8A0a9e27741E9DE8E88AED638e866";

    // ✅ Call eomRecon (End of Month Reconciliation) Signed by Provider
    console.log(`🔹 Calling EOM for user: ${user} with distributor: ${distributor}`);

    const tx = await contract.eomRecon(
        user,
        EpToken,
        EsToken,
        EoToken,
        peakODO,
        stdODO,
        offODO
    );

    await tx.wait();

    console.log("✅ Odometers updated, token balances recorded, distributor usage calculated, and bill generated!");
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});

