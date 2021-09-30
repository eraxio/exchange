// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners();

    console.log("owner address:", owner.address);


    const eraxProxyRegistry = await ethers.getContractAt("EraxProxyRegistry", "0x8a6f144af0FD56C9331029b8bab7C402702C6d02");

    console.log(eraxProxyRegistry.address);

    //部署  EraxExchange
    const EraxExchange = await ethers.getContractFactory("EraxExchange");
    //const eraxExchange = await EraxExchange.deploy(eraxProxyRegistry.address, eraxTokenTransferProxy.address, testToken.address, { gasLimit: 10000000000 });
    const eraxExchange = await EraxExchange.deploy(eraxProxyRegistry.address, "0x706fEb01d2ef39B258c39C4D5F6EfecBB31EC4D9");
    console.log("eraxExchange address:",eraxExchange.address);


    await eraxProxyRegistry.grantAuthentication(eraxExchange.address);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
