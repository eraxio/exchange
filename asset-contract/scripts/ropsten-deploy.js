// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners();

    //部署  WyvernProxyRegistry
    const AssetContractShared = await ethers.getContractFactory("AssetContractShared");
    const asetContractShared = await AssetContractShared.deploy("Erax Shared Asset", "ERAX", "0x8a6f144af0FD56C9331029b8bab7C402702C6d02", "https://api.erax.io");
    console.log("asetContractShared address:",asetContractShared.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
