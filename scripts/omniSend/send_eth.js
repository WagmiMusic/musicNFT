// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const { ethers } = require("hardhat");
// srcContract is on rinkeby
let srcChainId = 10001;
let srcAddr = process.env.ETH_CONTRACT_ADDRESS;
// dstContract is on mumbai
let dstChainId = 10009;
let dstAddr = process.env.MATIC_CONTRACT_ADDRESS;
let adapterParams = ethers.utils.solidityPack(["uint16", "uint256"], [1, 200000]) // default adapterParams example
let tokenId = 11;
let amount = 1;

async function main() {
  const signers = await ethers.getSigners()
  const owner = signers[0]
  const contractFactory = await ethers.getContractFactory("MusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  let tx = await contract.sendFrom(
    owner.address, 
    dstChainId, 
    owner.address, 
    tokenId, 
    amount, 
    owner.address, 
    ethers.constants.AddressZero, 
    adapterParams, 
    {  value: ethers.utils.parseEther("0.05") }
  )
  await tx.wait()
  console.log(`✅ [${hre.network.name}] send(${dstChainId}, ${tokenId}, ${amount})`)
  console.log(` tx: ${tx}`)
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });