require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("hardhat-gas-reporter");
require('hardhat-abi-exporter');
require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
//solidity: "0.8.3",

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.6",
  networks: {
    hardhat: {
      //gas: 67219750,
      //blockGasLimit: 67219750,
      //allowUnlimitedContractSize: true,
      //networkId: 31337,
      //port: 8544,
      accounts: [
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        },
        {
          privateKey: '',
          balance: '1000000000000000000000'
        }
      ]
    },
    localhost: {
      //gas: 67219750,
     // blockGasLimit: 67219750,
      //allowUnlimitedContractSize: true
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/842c54d9ac7442279c6ed1fd149749f7`,
      accounts: [``],
      gasPrice: 20000000000
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/842c54d9ac7442279c6ed1fd149749f7`,
      accounts: [``],
      gasPrice: 32000000000
    },
    matictest: {
      url: "https://rpc-mumbai.maticvigil.com/",
      chainId: 80001,
      gasPrice: 20000000000,
      accounts: [``]
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [``]
    },
    bscmain: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 5000000000,
      accounts: [``]
    },
    dextest: {
      url: "https://rpc.testnet.dex.io",
      chainId: 3603102,
      gasPrice: 20000000000,
      accounts: [``]
    }
  },
  gasReporter: {
    //enabled: true
  },
  abiExporter: {
    path: './data/abi',
    clear: true,
    flat: true,
    spacing: 2
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  }
};

