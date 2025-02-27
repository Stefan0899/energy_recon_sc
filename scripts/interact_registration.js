
const hre = require("hardhat");

async function main() {
    const contractAddress = "0x2Dd78Fd9B8F40659Af32eF98555B8b31bC97A351";  // ✅ Replace with actual contract address
    const owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";  // ✅ Replace with the owner's wallet address

    // ✅ Define new provider, distributor, and transmittor addresses
    const newProvider = "0xdD2FD4581271e230360230F9337D5c0430Bf44C0";  // ✅ Replace with the new provider's address
    const newDistributor = "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E";  // ✅ Replace with the new distributor's address
    const newTransmittor = "0xFABB0ac9d68B0B445fB7357272Ff202C5651694a";  // ✅ Replace with the new transmittor's address
    const newGenerator = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
    const userAddress = "0x71bE63f3384f5fb98995898A86B02Fb2426c5788";

    // ✅ Get deployed contract instance
    const signer = await hre.ethers.getSigner(owner); // Ensure the owner calls this function
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, signer);

    // ✅ Add Provider
    console.log(`🔹 Adding new provider: ${newProvider}`);
    let tx = await contract.addProvider(newProvider);
    await tx.wait();
    console.log(`✅ Provider added successfully: ${newProvider}`);

    // ✅ Add Distributor
    console.log(`🔹 Adding new distributor: ${newDistributor}`);
    tx = await contract.addDistributor(newDistributor);
    await tx.wait();
    console.log(`✅ Distributor added successfully: ${newDistributor}`);

    // ✅ Add Transmittor
    console.log(`🔹 Adding new transmittor: ${newTransmittor}`);
    tx = await contract.addTransmittor(newTransmittor);
    await tx.wait();
    console.log(`✅ Transmittor added successfully: ${newTransmittor}`);

    // ✅ Add Generator
    console.log(`🔹 Adding new generator: ${newGenerator}`);
    tx = await contract.addGenerator(newGenerator);
    await tx.wait();
    console.log(`✅ Generator added successfully: ${newGenerator}`);

    // ✅ Assign Provider
    tx = await contract.connect(await hre.ethers.getSigner(newProvider)).assignProviderToUser(userAddress);
    await tx.wait();
    console.log(`✅ Provider assigned: ${newProvider}`);

    // ✅ Assign Distributor
    tx = await contract.connect(await hre.ethers.getSigner(newDistributor)).assignDistributorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Distributor assigned: ${newDistributor}`);

    // ✅ Assign Transmittor
    tx = await contract.connect(await hre.ethers.getSigner(newTransmittor)).assignTransmittorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Transmittor assigned: ${newTransmittor}`);

    // ✅ Assign Generator
    tx = await contract.connect(await hre.ethers.getSigner(newGenerator)).assignGeneratorToUser(userAddress);
    await tx.wait();
    console.log(`✅ Generator assigned: ${newGenerator}`);
}

// Execute the script
main().catch((error) => {
    console.error("❌ Error adding provider/distributor/transmittor:", error.reason || error.message);
    process.exitCode = 1;
});


