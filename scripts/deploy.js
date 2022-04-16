const hre = require("hardhat");

const myAddr = "0xc4a67e2e63EfEC18679C00a96d72D1690EF14D39";
const toAddr = "0x16ea840cfA174FdAC738905C4E5dB59Fd86912a1";

async function main() {
  const factory = await hre.ethers.getContractFactory("MusicNFT");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log("NFT deployed to:", contract.address);
  const tx = await contract.safeTransferFrom(myAddr, toAddr, 1, 1, "0x");
  await tx.wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });