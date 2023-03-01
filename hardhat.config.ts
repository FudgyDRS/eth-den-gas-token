import type { HardhatUserConfig, NetworkUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-web3";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "solidity-coverage";
import "dotenv/config";

const config = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
      sepolia: '4MBCRQ5QXC12U81F8DG12HWQXCINEEM5D2'
    }
  },
  networks: {
    hardhat: {},
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545/",
      chainId: 97,
      accounts: [process.env.KEY_TESTNET],
    },
    sepoliaTestnet: {
      url: process.env.INFURA_API_SEPOLIA,
      chainId: 11155111,
      accounts: [process.env.KEY_TESTNET],
    },
    goreliTestnet: {
      url: process.env.ALCHEMY_API_GORELI,
      chainId: 5,
      accounts: [process.env.KEY_TESTNET],
    },
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  abiExporter: {
    path: "./data/abi",
    clear: true,
    flat: false,
  },
};

export default config;
