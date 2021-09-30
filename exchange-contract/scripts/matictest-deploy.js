// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners();

    console.log("owner address:", owner.address);

     //部署  EraxProxyRegistry
    const EraxProxyRegistry = await ethers.getContractFactory("EraxProxyRegistry");
    const eraxProxyRegistry = await EraxProxyRegistry.deploy();
    console.log("eraxProxyRegistry address:",eraxProxyRegistry.address);

    await eraxProxyRegistry.deployed();
    const delegateProxyImplementation = await eraxProxyRegistry.delegateProxyImplementation();
    console.log("delegateProxyImplementation address:",delegateProxyImplementation);


    //部署  EraxTokenTransferProxy
    const EraxTokenTransferProxy = await ethers.getContractFactory("EraxTokenTransferProxy");
    const eraxTokenTransferProxy = await EraxTokenTransferProxy.deploy(eraxProxyRegistry.address);
    console.log("eraxTokenTransferProxy address:",eraxTokenTransferProxy.address);

    //console.log("owner balance:", await ethers.provider.getBalance(owner.address));


    //部署  EraxExchange
    const EraxExchange = await ethers.getContractFactory("EraxExchange");
    //const eraxExchange = await EraxExchange.deploy(eraxProxyRegistry.address, eraxTokenTransferProxy.address, testToken.address, { gasLimit: 10000000000 });
    const eraxExchange = await EraxExchange.deploy(eraxProxyRegistry.address, eraxTokenTransferProxy.address, "0xf6c299bd8448668f087Ab0c678BF9016cf614245", owner.address);
    console.log("eraxExchange address:",eraxExchange.address);


    await eraxProxyRegistry.grantInitialAuthentication(eraxExchange.address);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
