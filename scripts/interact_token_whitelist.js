const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x045857BDEAE7C1c7252d611eB24eB55564198b4C"; // Replace with actual deployed factory address
    const newContractAddress = "0x2Dd78Fd9B8F40659Af32eF98555B8b31bC97A351"; // Replace with the contract that needs to call clawback()

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

