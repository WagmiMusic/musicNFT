// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const { ethers } = require("hardhat");
let srcAddr = process.env.ETH_CONTRACT_ADDRESS;
let owner = "";
let to

async function main() {
  const contractFactory = await ethers.getContractFactory("minMusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }

  try {
    let tx = await (await contract.safeBatchTransferFrom(owner, to, ids, amounts)).wait()
    console.log(`✅ [${hre.network.name}] safeBatchTransferFrom(${from}, ${to}, ${ids}, ${amounts})`)
  } catch (e) {
    if (e.error.message.includes("The trusted source address has already been set for the chainId")) {
        console.log("*trusted source already set*")
    } else {
        console.log(e)
    }
  }
}
main()