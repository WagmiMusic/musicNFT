const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const ONFT_ARGS = require("../constants/onftArgs.json")
const CHAIN_IDS = require("../constants/chainIds.json")

const lzEndpointAddress = LZ_ENDPOINTS["rinkeby"]
const onftArgs = ONFT_ARGS["rinkeby"]
const chainIds = CHAIN_IDS["mumbai"]

async function main() {
  const factory = await hre.ethers.getContractFactory("MusicNFT");
  const option = {
    gasPrice: 5 * 10**9
  }
  const contract = await factory.deploy(
    "hibikilla",
    "record",
    lzEndpointAddress, 
    onftArgs.startMintId, 
    onftArgs.endMintId, 
    chainIds,
    option
    );
  await contract.deployed();
  console.log("NFT deployed to:", contract.address);
  const gasPrice = contract.deployTransaction.gasPrice;
  const gasLimit = contract.deployTransaction.gasLimit;

  console.log("GasPrice(gwei):", gasPrice / 10**9);
  console.log("GasLimit:", gasLimit);
  console.log("GasFee:", ethers.utils.formatEther(gasPrice) * gasLimit)

  tx = await contract.mint(1,1);
  await tx.wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });