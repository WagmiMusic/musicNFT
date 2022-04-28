const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const ONFT_ARGS = require("../constants/onftArgs.json")
const CHAIN_IDS = require("../constants/chainIds.json")

const lzEndpointAddress = LZ_ENDPOINTS["rinkeby"]
const onftArgs = ONFT_ARGS["rinkeby"]
const chainIds = CHAIN_IDS["mumbai"]

async function main() {
  const factory = await hre.ethers.getContractFactory("SumpleNFT");
  const contract = await factory.deploy(
    "hibikilla",
    "record",
    onftArgs.startMintId, 
    onftArgs.endMintId, 
    chainIds
    );

  await contract.deployed();
  console.log("NFT deployed to:", contract.address);
  tx = await contract.mint(1,1);
  await tx.wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });