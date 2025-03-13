const hre = require("hardhat");

async function main() {
    const factoryAddress = "0x15381B00823186EAA183a0395aF91CeF90aB5905"; // Replace with actual factory address
    const recipient = "0xba539dF3129699C57148AF13E1027e7673bcC36C"; // Replace with actual user address
    const amount = hre.ethers.parseEther("100000000");

    const factory = await hre.ethers.getContractAt("EnergyTokenFactory", factoryAddress);

    console.log(`Minting 100 million Ep tokens to ${recipient}...`);
    await factory.mintEp(recipient, amount);
    console.log("✅ Minted Ep tokens");

    console.log(`Minting 100 million Es tokens to ${recipient}...`);
    await factory.mintEs(recipient, hre.ethers.parseEther("100000000"));
    console.log("✅ Minted Es tokens");

    console.log(`Minting 100 Eo tokens to ${recipient}...`);
    await factory.mintEo(recipient, hre.ethers.parseEther("100000000"));
    console.log("✅ Minted Eo tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
