const { privateKey, alchemyApiKey } = require("./secrets.json");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');

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
  gasReporter: {
    currency: 'JPY',
    coinmarketcap: 'e9a2f0b2-8e69-4298-8d70-89b9a0064144',
    token: 'ETH',
    gasPrice: 40
  },
  contractSizer: {
    alphaSort: false,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  networks: {
    hardhat: {},
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + alchemyApiKey,
      chainId: 4,
      accounts: [ privateKey ]
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + alchemyApiKey,
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
  etherscan: {
    apiKey: "UUT8BA1URMCD5JPPN4YFJ8UYGYHQZ2FFBH"
  }
};