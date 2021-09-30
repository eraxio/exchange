// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners();

    console.log("owner address:", owner.address);


    /*const eraxProxyRegistry = await ethers.getContractAt("EraxProxyRegistry", "0xd5B9e02fbc12Fe0C5F67205545deeCE6eE3D0352");

    console.log(eraxProxyRegistry.address);

     const EraxExchange = await ethers.getContractFactory("EraxExchange");
     const eraxExchange = await EraxExchange.deploy(eraxProxyRegistry.address, "0x1e6b51191FC6582F1b44a794022fc8352414A22F");
    console.log("eraxExchange address:",eraxExchange.address);


    await eraxProxyRegistry.grantAuthentication(eraxExchange.address);*/

    const eraxExchange = await ethers.getContractAt("EraxExchange", "0x6F1D0E4574eECbAB34c083085C3c8856864A6C43");
    await eraxExchange.addSharedProxyAddress("0xc2195146E3aadeAACF971F4714a95ff545106AD8");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
