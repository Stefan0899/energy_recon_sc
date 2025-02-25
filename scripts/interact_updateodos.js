const hre = require("hardhat");

async function main() {
    const contractAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";  // ✅ Replace with deployed contract address
    const providerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"; // ✅ Explicitly define the provider
    const provider = await hre.ethers.getSigner(providerAddress); // ✅ Explicitly get signer for this address
    const user = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";  // ✅ Replace with a test user wallet

    // ✅ Get deployed contract instance
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Provider (${provider.address}) updating ODO readings for: ${user}`);

    // ✅ Define ODO readings
    const peakODO = 767; //+200
    const stdODO = 408; //+100
    const offODO = 392; //+100

    // ✅ Replace with deployed token addresses
    const E1Token = "0x6F1216D1BFe15c98520CA1434FC1d9D57AC95321";
    const E2Token = "0xdAD42D43ecE0f6e8da8c2BCbC6A25FF6b3922C58";
    const E3Token = "0xCBd5431cC04031d089c90E7c83288183A6Fe545d";

    // ✅ Call updateOdometersAndCalculateBill (ODOs must be pre-calculated)
    const tx = await contract.updateOdometersAndCalculateBill(user, E1Token, E2Token, E3Token, peakODO, stdODO, offODO);
    await tx.wait();

    console.log("✅ Odometers updated, token balances recorded, distributor usage calculated, and bill generated!");

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});


