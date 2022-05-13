// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const LZ_ENDPOINTS = require("../../constants/layerzeroEndpoints.json")
const ONFT_ARGS = require("../../constants/onftArgs.json")

const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
const onftArgs = ONFT_ARGS[hre.network.name]

async function main() {
  const factory = await hre.ethers.getContractFactory("MusicNFT");
  // const option = {
  //   gasPrice: 150 * 10**9
  // }
  const contract = await factory.deploy(
    "WAGMI Music",
    "disc",
    "0x3c2269811836af69497E5F486A85D7316753cf62",
    1, 
    7
  );
  await contract.deployed();
  console.log("NFT deployed to:", contract.address);
  const gasPrice = contract.deployTransaction.gasPrice;
  const gasLimit = contract.deployTransaction.gasLimit;

  console.log("GasPrice(gwei):", gasPrice / 10**9);
  console.log("GasLimit:", gasLimit);
  console.log("GasFee:", ethers.utils.formatEther(gasPrice) * gasLimit)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });