const hre = require("hardhat");

async function main() {
    const contractAddress = "0x2Dd78Fd9B8F40659Af32eF98555B8b31bC97A351";  // ✅ Replace with deployed contract address
    const providerAddress = "0xdD2FD4581271e230360230F9337D5c0430Bf44C0"; // ✅ Explicitly define the provider
    const provider = await hre.ethers.getSigner(providerAddress); // ✅ Explicitly get signer for this address
    const user = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788";  // ✅ Replace with a test user wallet
    const distributor = "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E"; // ✅ Distributor address (must match assigned distributor)

    // ✅ Get deployed contract instance
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Provider (${provider.address}) updating ODO readings for: ${user}`);

    // ✅ Define ODO readings
    const peakODO = 867; //+200
    const stdODO = 608; //+100
    const offODO = 482; //+100

    // ✅ Replace with deployed token addresses
    const E1Token = "0xd5a0A480AC9500C3b81de52A7b604c45eAE2868f";
    const E2Token = "0xBbD369799F35E103adD073ef1f6Ec8aBC29f2Fbc";
    const E3Token = "0x6c6b5D794f95772AAb3826172DF3D2342E354fcB";

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