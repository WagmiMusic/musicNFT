const { privateKey, polygonscanApiKey, etherscanApiKey, alchemyApiKey } = require("./secrets.json");

require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');

module.exports = {
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {},
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + alchemyApiKey,
      chainId: 4,
      accounts: [ privateKey ]
    },
    matic_mainnet: {
      url: "https://matic-mainnet.chainstacklabs.com",
      chainId: 137,
      accounts: [ privateKey ]
    },
    matic_testnet: {
      url: "https://matic-mumbai.chainstacklabs.com",
      chainId: 80001,
      accounts: [ privateKey ]
    }
  },
};