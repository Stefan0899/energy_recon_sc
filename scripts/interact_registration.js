
const hre = require("hardhat");

async function main() {
    const contractAddress = "0xE43Ef8DCA60e3fa24Af647D32DDf8BfB041d69aa";  // ✅ Replace with actual contract address
    const owner = "0xba539dF3129699C57148AF13E1027e7673bcC36C";  // ✅ Replace with the owner's wallet address

    // ✅ Define new provider, distributor, and transmittor addresses
    const newProvider = "0x9DF18672f31A9b48b2C34405ce6EfE80A95514f8";  // ✅ Replace with the new provider's address
    const newDistributor = "0x57D5d45C25C7185008aE9E8Aa0C951092AF64588";  // ✅ Replace with the new distributor's address
    const newTransmittor = "0x21b34Aa299e73a11AB23895478eee6df6EBD188D";  // ✅ Replace with the new transmittor's address
    const newGenerator = "0x6a32eD244A0D3C8e124033e74e9235D160605CF4";
    const userAddress = "0x393d98362B7C09118a3CD4C179c6322C6F9456A3";

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

}

// Execute the script
main().catch((error) => {
    console.error("❌ Error adding provider/distributor/transmittor:", error.reason || error.message);
    process.exitCode = 1;
});


