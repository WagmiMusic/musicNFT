// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

//this scripts is for rinkeby Chain
const { ethers } = require("hardhat");
let srcAddr = process.env.MATIC_CONTRACT_ADDRESS;
let addressArray = [
  "0xAd84F848Efb88C7D2aC9e0e8181861a995041D71",
  "0x923fC9eE70CCba05b6CbB2737961E1D775784576",
  "0xFcdB212E7e7588D2dd2cc44C30F6C79fB507DB4B",
  "0x7b5f4aad61edAA53491810ebC62804169Bb3D3cD",
  "0x43F413435bFE9f6EbE8f866d363AE1c2F466e466",
  "0x74Ec3f1a9Ed462869F1c322370Ba288c60Ce9f5c",
  "0x4cFD7de2825316cD9b9d03fA18842c41863c72EE",
  "0x59B0899e84d1f0C23960B3dF42a062E5aCA9a573",
  "0x61726d19425CAEf0a55b193a8E50B2e946C698D8",
  "0x12312dAf82C5aD5f5C1C7e28A48e8831b7e1DF3d",
  "0xeE2778597A1Cb1c3d1B493C9370f57818C35eE9a",
  "0x17e845e8F6B5Bc93d9200C47E0A42eE0A9345ACc",
  "0xdbf37c5ae62bd82967cF4aF1e01FC4506CE9CB8A",
  "0x5ab408861018683c73c444355d78d214805cb558",
  "0x0dAE5FcaD0DF8E5C029D76927582DFBdFd7eeC79",
  "0x4808e6541f88ba5f75ba9654369613C9aE19d718",
  "0xeD28ea306d3C110549F9B2FAcbfE6E3175517500",
  "0xF10F87D0885F846EEfdfeCD99d31e1EA21f8608F",
  "0x458A4c01b16830BBE4a98027A750DF9c34A46cf8",
  "0xe977315fB1650192359c56A8eFD90B17Ff7Cc6F5",
  "0x7177EBc64081868D5bCBccfbc651FDc0B4020ff6",
  "0x392Dc129d0FFe7D1ECdc79A73Ce9e4b938d83709",
  "0xC1aA83241114305f548fFcD558c4f7af7F15761E",
  "0xd30f4515D478e196434610a090F0EFeD18A464A9",
  "0x3BF9f6AC578e0dec6121c72c4AdC9735c051DB03",
  "0x79e3baf01d8d985a02c8bdad205673b1a8a8c85c",
  "0x2c3ed0211d5ea74ce3da545b7af217e4284ea030",
  "0x6Ad60bacf404935f5e934786Ca7e131AE53642AB",
  "0x18B96943ca1a2B3bEbe0f0c1936F5b056Fe6c297",
  "0xef83a287ded45962997584174ddb2c68dc215e3b",
  "0xf7d2EaDDBEdc13ee055C68f916885E5AcD231574",
  "0x6b62BA1Cc3ee2469B9C8511FdcA31E56F327B75A",
  "0x0c25c74b1017cB8830C8476372Fb28be826743C9"
];

async function main() {
  const contractFactory = await ethers.getContractFactory("minMusicNFT");
  const contract = await contractFactory.attach(srcAddr);
  // const option = {
  //   gasPrice: 10 * 10**9
  // }

  try {
    let tx = await (await contract.addAllowlist(addressArray)).wait()
    console.log(`✅ [${hre.network.name}] addAllowlist(${addressArray})`)
  } catch (e) {
    if (e.error.message.includes("The trusted source address has already been set for the chainId")) {
        console.log("*trusted source already set*")
    } else {
        console.log(e)
    }
  }
}
main()