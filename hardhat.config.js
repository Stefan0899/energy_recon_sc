require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true, // ✅ Enables IR-based compilation to reduce stack depth issues
    }
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [
        process.env.OWNER_PRIVATE_KEY, 
        process.env.PROVIDER_PRIVATE_KEY,
        process.env.DISTRIBUTOR_PRIVATE_KEY,
        process.env.TRANSMITTOR_PRIVATE_KEY,
        process.env.GENERATOR_PRIVATE_KEY
      ].filter(Boolean), // ✅ Ensures only valid keys are used (removes undefined values)
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY, // ✅ Etherscan API key for contract verification
    },
  },
};



