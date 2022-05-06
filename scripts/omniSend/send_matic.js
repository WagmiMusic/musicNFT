// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for mumbai Chain
const { ethers } = require("hardhat");
// srcContract is on mumbai
let srcChainId = 10009;
let srcAddr = process.env.MATIC_CONTRACT_ADDRESS;;
// srcContract is on rinkeby
let dstChainId = 10001;
let dstAddr = process.env.ETH_CONTRACT_ADDRESS;;
let adapterParams = ethers.utils.solidityPack(["uint16", "uint256"], [1, 200000]) // default adapterParams example

async function main() {
  const contractFactory = await ethers.getContractFactory("minMusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  let tx = await contract.simpleSend(
    1,
    1,
    "0x16ea840cfA174FdAC738905C4E5dB59Fd86912a1",
    adapterParams,
    { value: ethers.utils.parseEther("0.5") }
  )
  await tx.wait()
  console.log(`✅ [${hre.network.name}] omniSend(${dstChainId}, ${dstAddr})`)
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });