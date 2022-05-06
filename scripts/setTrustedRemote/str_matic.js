// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for matic Chain
const { ethers } = require("hardhat");
// srcContract is on matic
let srcChainId = 10009;
let srcAddr = process.env.MATIC_CONTRACT_ADDRESS;
// dstContract is on mumbai
let dstChainId = 10001;
let dstAddr = process.env.ETH_CONTRACT_ADDRESS;

async function main() {
  const contractFactory = await ethers.getContractFactory("MusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }
  
  try {
    let tx = await (await contract.setTrustedRemote(dstChainId, dstAddr)).wait()
    console.log(`✅ [${hre.network.name}] setTrustedRemote(${dstChainId}, ${dstAddr})`)
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