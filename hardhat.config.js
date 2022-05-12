const { privateKey, alchemyApiKey, polygonscanApiKey, etherscanApiKey } = require("./secrets.json");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
require("solidity-coverage");
// require('hardhat-deploy');
// require('hardhat-deploy-ethers');
// require('./tasks');

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
    gasPrice: 20
  },
  contractSizer: {
    alphaSort: false,
    runOnCompile: false,
    disambiguatePaths: false,
  },
  networks: {
    hardhat: {},
    // ethereum: {
    //   url: "https://eth-mainnet.alchemyapi.io/v2/" + alchemyApiKey,
    //   gasPrice: 10 * 10**9,
    //   chainId: 1,
    //   accounts: [ privateKey ]
    // },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + alchemyApiKey,
      gasPrice: 10 * 10**9,
      chainId: 4,
      accounts: [ privateKey ]
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + alchemyApiKey,
      chainId: 5,
      accounts: [ privateKey ]
    },
    polygon: {
      url: "https://matic-mainnet.chainstacklabs.com",
      chainId: 137,
      accounts: [ privateKey ],
      // gasPrice: 120 * 10**9,
    },
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com",
      chainId: 80001,
      accounts: [ privateKey ]
    }
  },
  etherscan: {
    // apiKey: etherscanApiKey // EtherscanでVerifyする際にコメントアウトを外して使用
    apiKey: polygonscanApiKey // PolygonscanでVerifyする際にコメントアウトを外して使用
  }
};