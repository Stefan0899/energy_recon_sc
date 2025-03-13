const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x15381B00823186EAA183a0395aF91CeF90aB5905"; // Replace with actual deployed factory address
    const newContractAddress = "0xB16103De3B577C8384157A7B15660bA97469DBA8"; // Replace with the contract that needs to call clawback()

    // Get the deployed EnergyTokenFactory contract
    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    console.log(`Whitelisting contract: ${newContractAddress}...`);

    // Step 1: Whitelist another contract to allow it to call clawback
    const tx = await factory.addAuthorizedContract(newContractAddress);
    await tx.wait();
    console.log(`Contract ${newContractAddress} whitelisted successfully!`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

