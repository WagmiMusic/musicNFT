// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const { ethers } = require("hardhat");
let srcAddr = process.env.ETH_CONTRACT_ADDRESS;
let tokenIds = [1, 2];
let amounts = [5, 5];
let dstAddress = "0xAd84F848Efb88C7D2aC9e0e8181861a995041D71";

async function main() {
  const contractFactory = await ethers.getContractFactory("MusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }

  try {
    let tx = await (await contract.mintBatch(dstAddress, tokenIds, amounts)).wait()
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