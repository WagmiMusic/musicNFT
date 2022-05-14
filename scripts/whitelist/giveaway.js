// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const { ethers } = require("hardhat");
let srcAddr = process.env.MATIC_CONTRACT_ADDRESS;
let owner = "0xAd84F848Efb88C7D2aC9e0e8181861a995041D71";
let to = "0xa0F0b6F5faBea79E61Bd3D5B0D30B050d58f1C13";
let ids = [5, 3, 4, 6];
let amounts = [10, 5, 55, 10];

async function main() {
  const contractFactory = await ethers.getContractFactory("MusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }
  let tx = await (await contract.safeBatchTransferFrom(owner, to, ids, amounts, 0x0)).wait()
    console.log(`✅ [${hre.network.name}] safeTransferFrom(${owner}, ${to}, ${ids}, ${amounts})`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });