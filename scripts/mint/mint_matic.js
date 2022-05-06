// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for mumbai Chain
const { ethers } = require("hardhat");
let srcAddr = process.env.MATIC_CONTRACT_ADDRESS;
let tokenIds = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
let amounts = [1, 10, 10, 1, 2, 20, 5, 5, 2, 10, 5, 5, 9];

async function main() {
  const contractFactory = await ethers.getContractFactory("MusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }

  try {
    let tx = await (await contract.mintBatch(tokenIds, amounts)).wait()
    console.log(`✅ [${hre.network.name}] mintBatch(${tokenIds}, ${amounts})`)
    console.log(` tx: ${tx.transactionHash}`)
  } catch (e) {
    if (e.error.message.includes("The trusted source address has already been set for the chainId")) {
        console.log("*trusted source already set*")
    } else {
        console.log(e)
    }
  }
}
main()