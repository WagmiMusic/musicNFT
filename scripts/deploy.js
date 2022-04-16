const hre = require("hardhat");

const tokenURI = "https://ipfs.moralis.io:2053/ipfs/QmUpTJ1yUV4QREEjoeUQTwFFr7RGMf9sHcWu5AFL7y3PVB"

async function main() {
  const factory = await hre.ethers.getContractFactory("MusicNFT");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log("NFT deployed to:", contract.address);
  const tx = await contract.mint(tokenURI)
  await tx.wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });