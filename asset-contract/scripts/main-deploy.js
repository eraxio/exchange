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
    const asetContractShared = await AssetContractShared.deploy("Erax Shared Asset", "ERAX", "0xd5B9e02fbc12Fe0C5F67205545deeCE6eE3D0352", "https://api.erax.io");
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
