const hre = require("hardhat");

async function main() {
    const contractAddress = "0x5D42EBdBBa61412295D7b0302d6F50aC449Ddb4F";  // ✅ Replace with deployed contract address
    const providerAddress = "0xdD2FD4581271e230360230F9337D5c0430Bf44C0"; // ✅ Explicitly define the provider
    const provider = await hre.ethers.getSigner(providerAddress); // ✅ Explicitly get signer for this address
    const user = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  // ✅ Replace with a test user wallet
    const distributor = "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E"; // ✅ Distributor address (must match assigned distributor)

    // ✅ Get deployed contract instance
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Provider (${provider.address}) updating ODO readings for: ${user}`);

    // ✅ Define ODO readings
    const peakODO = 767; //+200
    const stdODO = 408; //+100
    const offODO = 392; //+100

    // ✅ Replace with deployed token addresses
    const E1Token = "0xa16E02E87b7454126E5E10d957A927A7F5B5d2be";
    const E2Token = "0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968";
    const E3Token = "0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883";

    // ✅ Call updateOdometersAndCalculateBill with distributor address
    console.log(`🔹 Calling EOM for user: ${user} with distributor: ${distributor}`);

    const tx = await contract.eomRecon(
        user, 
        E1Token, 
        E2Token, 
        E3Token, 
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