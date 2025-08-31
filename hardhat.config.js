require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
require("@nomicfoundation/hardhat-verify");
require('@openzeppelin/hardhat-upgrades');
require("@nomicfoundation/hardhat-chai-matchers");

const { BSC_TESTNET_RPC_URL, BSC_TESTNET_PRIVATE_KEY, BSC_APIKEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  defaultNetwork: "bscTestnet",
  networks: {
    bscTestnet: {
      url: BSC_TESTNET_RPC_URL,
      accounts: [`0x${BSC_TESTNET_PRIVATE_KEY}`],
      gas: "auto",
      gasPrice: "auto",
    },
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true,
      throwOnCallFailures: true,
      throwOnTransactionFailures: true,
      loggingEnabled: true,
    }
  },
  etherscan: {
    apiKey:{
      bscTestnet: BSC_APIKEY,
    },
    customChains: [
      {
        network: "bscTestnet",
        chainId: 97,
        urls: {
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL: "https://testnet.bscscan.com",
        },
      },
    ]
  },

  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  }
};