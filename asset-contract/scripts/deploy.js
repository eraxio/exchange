// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

    const [owner, addr1, addr2] = await ethers.getSigners();

    //部署  WyvernProxyRegistry
    const AssetContractShared = await ethers.getContractFactory("AssetContractShared");
    const asetContractShared = await AssetContractShared.deploy("Joe Shared Asset", "JOESTORE", "0x11D3B93040EEDFB22cb677Ad04E0254970a49314", "https://testnets-api.opensea.io/api/v1/metadata/0xeE45B41D1aC24E9a620169994DEb22739F64f231/0x{id}");
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
