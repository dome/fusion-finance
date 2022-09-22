require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-deploy");
require("dotenv").config();

module.exports = {
  namedAccounts: {
    deployer: {
      default: 1,
      17: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      35: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      97: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      56: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      96: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      137: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      555: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      80001: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      1001: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3501: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3502: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      703: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
    },
    dev: {
      // Default to 1
      default: 1,
      // dev address mainnet
      // 1: "",
      17: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      35: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      56: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      97: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      96: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      137: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      555: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      80001: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      1001: "0xBC0EE23C8A355f051a9309bce676F818d35743D1",
      3501: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3502: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      703: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
    },
    feeCollector1:{
      3501: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3502: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      703: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
    },
    feeCollector2:{
      3501: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3502: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      703: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
    },    
    collector: {
      default: 1,
      17: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      35: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      97: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      56: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      96: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      137: "0xcD64a1fb76085F6184C1A8592f44DcF713EAD517",
      555: "0xcD64a1fb76085F6184C1A8592f44DcF713EAD517",
      80001: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      1001: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3501: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",
      3502: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",   
      703: "0x4A4cF4741a96D8e0123a490cA720d84fD9b15bc4",   
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.GOERLI_RPC,
      },
      chainId: 1337,
    },
    goerli: {
      url: process.env.GOERLI_RPC,
      gasPrice: 50000000000,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 5,
    },
    tch: {
      url: "https://rpc.tch.dev",
      accounts: [process.env.PRIVATE_KEY],
      live: true,
      saveDeployments: true,
      tags: ["production"],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
