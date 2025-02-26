const hre = require("hardhat");

async function main() {
    const contractAddress = "0xc0F115A19107322cFBf1cDBC7ea011C19EbDB4F8"; // ✅ Replace with deployed contract address
    const userAddress = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"; // ✅ User address
    const distributorAddress = "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E"; // ✅ Distributor who assigned the tariff
    const transmittorAddress = "0xFABB0ac9d68B0B445fB7357272Ff202C5651694a";
    const generatorAddress = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"; // ✅ Transmittor who assigned the tariff

    const provider = await hre.ethers.getSigner(distributorAddress);
    const contract = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, provider);

    console.log(`🔹 Setting distributor tariffs for user: ${userAddress}`);

    // ✅ Define distributor tariff values
    const peakTariff = 240;  
    const standardTariff = 150;
    const offpeakTariff = 120;
    const basicTariff = 11000;

    // ✅ Set the distributor tariff in the contract
    let txSetTariff = await contract.setTariff(1, peakTariff, standardTariff, offpeakTariff, basicTariff);
    await txSetTariff.wait();
    console.log("✅ Distributor Tariff set successfully!");

    // ✅ Assign the distributor tariff to the user
    console.log(`🔹 Assigning distributor tariff to user: ${userAddress}`);
    let txAssignTariff = await contract.assignTariffToUser(userAddress, 1);
    await txAssignTariff.wait();
    console.log("✅ Distributor Tariff assigned successfully!");

    // ✅ Fetch and display the user's distributor tariff
    console.log(`🔹 Fetching distributor tariff for user: ${userAddress}`);
    const distributorTariffs = await contract.getUserTariffs(userAddress);

    console.log(`✅ Retrieved Distributor Tariffs for ${userAddress}:`);
    console.log(`   - Peak Tariff: ${distributorTariffs[0]} units`);
    console.log(`   - Standard Tariff: ${distributorTariffs[1]} units`);
    console.log(`   - Off-Peak Tariff: ${distributorTariffs[2]} units`);
    console.log(`   - Basic Tariff: ${distributorTariffs[3]} units`);
    console.log(`   - Assigned Distributor: ${distributorTariffs[4]}`);
    console.log(`   - Tariff ID: ${distributorTariffs[5]}`);

    // ✅ Switch to Transmittor Signer
    const transmittorProvider = await hre.ethers.getSigner(transmittorAddress);
    const contractTransmittor = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, transmittorProvider);

    console.log(`🔹 Setting transmittor tariffs for user: ${userAddress}`);

    // ✅ Define transmittor tariff values
    const transmittorPeakTariff = 220;
    const transmittorStandardTariff = 110;
    const transmittorOffpeakTariff = 100;
    const transmittorBasicTariff = 0;

    // ✅ Set the transmittor tariff in the contract
    let txSetTransmittorTariff = await contractTransmittor.setTransmittorTariff(1, transmittorPeakTariff, transmittorStandardTariff, transmittorOffpeakTariff, transmittorBasicTariff);
    await txSetTransmittorTariff.wait();
    console.log("✅ Transmittor Tariff set successfully!");

    // ✅ Assign the transmittor tariff to the user
    console.log(`🔹 Assigning transmittor tariff to user: ${userAddress}`);
    let txAssignTransmittorTariff = await contractTransmittor.assignTransmittorTariffToUser(userAddress, 1);
    await txAssignTransmittorTariff.wait();
    console.log("✅ Transmittor Tariff assigned successfully!");

    // ✅ Fetch and display the user's transmittor tariff
    console.log(`🔹 Fetching transmittor tariff for user: ${userAddress}`);
    const transmittorTariffs = await contractTransmittor.getUserTransmittorTariffs(userAddress);

    console.log(`✅ Retrieved Transmittor Tariffs for ${userAddress}:`);
    console.log(`   - Peak Tariff: ${transmittorTariffs[0]} units`);
    console.log(`   - Standard Tariff: ${transmittorTariffs[1]} units`);
    console.log(`   - Off-Peak Tariff: ${transmittorTariffs[2]} units`);
    console.log(`   - Basic Tariff: ${transmittorTariffs[3]} units`);
    console.log(`   - Assigned Transmittor: ${transmittorTariffs[4]}`);
    console.log(`   - Tariff ID: ${transmittorTariffs[5]}`);

    // ✅ Switch to Generator Signer
    const generatorProvider = await hre.ethers.getSigner(generatorAddress);
    const contractGenerator = await hre.ethers.getContractAt("SimplePayment_v1_o_up", contractAddress, generatorProvider);

    console.log(`🔹 Setting generator tariffs for user: ${userAddress}`);

    // ✅ Define transmittor tariff values
    const generatorPeakTariff = 200;
    const generatorStandardTariff = 100;
    const generatorOffpeakTariff = 80;
    const generatorBasicTariff = 0;

    // ✅ Set the transmittor tariff in the contract
    let txSetGeneratorTariff = await contractGenerator.setGeneratorTariff(1, generatorPeakTariff, generatorStandardTariff, generatorOffpeakTariff, generatorBasicTariff);
    await txSetGeneratorTariff.wait();
    console.log("✅ Generator Tariff set successfully!");

    // ✅ Assign the transmittor tariff to the user
    console.log(`🔹 Assigning generator tariff to user: ${userAddress}`);
    let txAssignGeneratorTariff = await contractGenerator.assignGeneratorTariffToUser(userAddress, 1);
    await txAssignGeneratorTariff.wait();
    console.log("✅ Generator Tariff assigned successfully!");

    // ✅ Fetch and display the user's transmittor tariff
    console.log(`🔹 Fetching generator tariff for user: ${userAddress}`);
    const generatorTariffs = await contractGenerator.getUserGeneratorTariffs(userAddress);

    console.log(`✅ Retrieved Generator Tariffs for ${userAddress}:`);
    console.log(`   - Peak Tariff: ${generatorTariffs[0]} units`);
    console.log(`   - Standard Tariff: ${generatorTariffs[1]} units`);
    console.log(`   - Off-Peak Tariff: ${generatorTariffs[2]} units`);
    console.log(`   - Basic Tariff: ${generatorTariffs[3]} units`);
    console.log(`   - Assigned Generator: ${generatorTariffs[4]}`);
    console.log(`   - Tariff ID: ${generatorTariffs[5]}`);
}

main().catch((error) => {
    console.error("❌ Error:", error.reason || error.message);
    process.exitCode = 1;
});



