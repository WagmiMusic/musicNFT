const { BN } = require('@openzeppelin/test-helpers');
const { expect } = require("chai")
const { config } = require("dotenv")
const { ethers } = require("hardhat")

describe("main", () => {
  const chainIdSrc = 1
  const chainIdDst = 2

  let owner, alice, bob, lzEndpointSrcMock, lzEndpointDstMock, ONFTSrc, ONFTDst, LZEndpointMock, ONFT, ONFTSrcIds, ONFTDstIds

  before(async () => {
    owner = (await ethers.getSigners())[0]
    alice = (await ethers.getSigners())[1]
    bob = (await ethers.getSigners())[2]

    LZEndpointMock = await ethers.getContractFactory("LZEndpointMock")
    ONFT = await ethers.getContractFactory("minMusicNFT")
    ONFTSrcIds = [1, 5] // [startID, endID]... only allowed to mint one ONFT
    ONFTDstIds = [6, 20] // [startID, endID]... only allowed to mint one ONFT
  })

  beforeEach(async () => {
    lzEndpointSrcMock = await LZEndpointMock.deploy(chainIdSrc)
    lzEndpointDstMock = await LZEndpointMock.deploy(chainIdDst)

    ONFTSrc = await ONFT.deploy(
      "hibikilla",
      "record",
      lzEndpointSrcMock.address,
      ...ONFTSrcIds,
      chainIdDst
    )
    ONFTDst = await ONFT.deploy(
      "hibikilla",
      "record",
      lzEndpointDstMock.address,
      ...ONFTDstIds,
      chainIdSrc
    )

    lzEndpointSrcMock.setDestLzEndpoint(ONFTDst.address, lzEndpointDstMock.address)
    lzEndpointDstMock.setDestLzEndpoint(ONFTSrc.address, lzEndpointSrcMock.address)

    await ONFTSrc.setTrustedRemote(chainIdDst, ONFTDst.address)
    await ONFTDst.setTrustedRemote(chainIdSrc, ONFTSrc.address)

    await ONFTSrc.startSale()
    await ONFTDst.startSale()
  })

  describe("Most basic test", () => {
    beforeEach(async () => {
      await ONFTSrc.releasedLimitations()
    })
    it("mint", async () => {
      const mintId = 1
      const mintAmount = 1
      await ONFTSrc.mint(mintId, mintAmount)
      expect(await ONFTSrc.balanceOf(owner.address, mintId)).to.be.equal(mintAmount)
    })
    it("mintBatch", async () => {
      const mintIds = [1, 2]
      const mintAmounts = [1, 2]
      await ONFTSrc.mintBatch(mintIds, mintAmounts)
      expect(await ONFTSrc.balanceOf(owner.address, mintIds[0])).to.be.equal(mintAmounts[0])
    })
    xit("transfer", async () => {
      const mintId = 1
      const mintAmount = 1
      await ONFTSrc.mint(mintId, mintAmount)
      await ONFTSrc.safeTransferFrom(owner.address, alice.address, mintId, mintAmount, 0x0)
      await ONFTSrc.connect(alice).safeTransferFrom(alice.address, bob.address, mintId, mintAmount, 0x0)
      expect(await ONFTSrc.balanceOf(bob.address, mintId)).to.be.equal(mintAmount)
    })
    it("startSale and suspendSale", async () => {
      const mintId = 1
      const mintAmount = 1
      await ONFTSrc.mint(mintId, mintAmount)
      await ONFTSrc.suspendSale()
      await expect(ONFTSrc.safeTransferFrom(owner.address, alice.address, mintId, mintAmount, 0x0)).to.be.reverted;
    } )
    xit("reveal", async () => {

    })
    xit("EMGreveal", async () => {
      
    })
    it("license and unlicense", async () => {
      const mintId = 1
      const mintAmount = 1
      await ONFTSrc.mint(mintId, mintAmount)
      await ONFTSrc.license(alice.address)
      await ONFTSrc.connect(alice).suspendSale()
      await expect(ONFTSrc.safeTransferFrom(owner.address, alice.address, mintId, mintAmount, 0x0)).to.be.reverted;
    })
  })

  xit("Normal test - mint and transfer", async () => {
    const mintId = 18;
    const mintAmount = 1;
    const InvalidMintAmount = 10;
  
    await expect(ONFTSrc.mint(mintId,mintAmount)).to.be.revertedWith('tokenId is not allowed on this chain');

    await ONFTDst.mint(mintId,mintAmount)

    await expect(ONFTDst.mint(mintId,InvalidMintAmount)).to.be.revertedWith('Max supply reached')

    await ONFTDst.safeTransferFrom(owner.address, alice.address, mintId, mintAmount, 0x0)

    await expect(await ONFTDst.balanceOf(alice.address, mintId)).to.be.equal(mintAmount)
  })

  describe("Sale restriction", () => {
    it("Confirmation of giveaway/Raffle", async () => {
      const mintId = 1 
      const mintAmount = 2; //MaxMint:1
      await expect(ONFTDst.mint(mintId, mintAmount)).to.be.reverted;
    })
  
    it("Confirmation of presale", async () => {
      const mintId = 2; 
      const mintAmount = 2; //MaxMint:3
      await ONFTSrc.mint(mintId, mintAmount)
      await expect(ONFTSrc.mint(mintId, mintAmount)).to.be.revertedWith('Max supply reached');
      await ONFTSrc.addAllowlist(alice.address)
      await expect(ONFTSrc.safeTransferFrom(owner.address, alice.address, mintId, mintAmount, 0x0)).to.be.revertedWith("Can't buy same songs more than two record")
    })
  
    xit("Confirmation of public sale", async () => {
      const mintId = 5;
      const mintAmount = 2; //MaxMint:2
      await ONFTDst.mint(mintId, mintAmount)
      await ONFTDst.safeTransferFrom(owner.address, alice.address, mintId, 1, 0x0)
      await ONFTDst.safeTransferFrom(owner.address, bob.address, mintId, 1, 0x0)
      await ONFTDst.connect(bob).safeTransferFrom(bob.address, alice.address, mintId, 1, 0x0)
      expect(await ONFTDst.balanceOf(alice.address, mintId)).to.be.equal(2)
    })
  })

  describe("Omunichain test", () => {
    it("mint on Src chian and send to Dst chain", async () => {
      const mintId = 1;
      const mintAmount = 1;
  
      await ONFTSrc.mint(mintId,mintAmount)
      expect(await ONFTSrc.balanceOf(owner.address, mintId)).to.be.equal(mintAmount)
  
      // await ONFTSrc.releasedLimitations()
  
      const adapterParam = ethers.utils.solidityPack(["uint16", "uint256"], [1, 225000])
  
      await ONFTSrc.sendFrom(
        owner.address,
        chainIdDst,
        ethers.utils.solidityPack(["address"], [owner.address]),
        mintId,
        mintAmount,
        owner.address,
        "0x0000000000000000000000000000000000000000",
        adapterParam
      )
      const srcAmount = await ONFTSrc.balanceOf(owner.address, mintId)
      await expect(srcAmount).to.be.equal(0)
  
      const dstAmount = await ONFTDst.balanceOf(owner.address, mintId)
      await expect(dstAmount).to.be.equal(mintAmount)
    })

    it("mint on Src chian and simpleSend to Dst chain", async () => {
      const mintId = 1;
      const mintAmount = 1;
  
      await ONFTSrc.mint(mintId,mintAmount)
      expect(await ONFTSrc.balanceOf(owner.address, mintId)).to.be.equal(mintAmount)
  
      // await ONFTSrc.releasedLimitations()
  
      const adapterParam = ethers.utils.solidityPack(["uint16", "uint256"], [1, 225000])
  
      await ONFTSrc.simpleSend(
        mintId,
        mintAmount,
        owner.address,
        adapterParam
      )
      const srcAmount = await ONFTSrc.balanceOf(owner.address, mintId)
      await expect(srcAmount).to.be.equal(0)
  
      const dstAmount = await ONFTDst.balanceOf(owner.address, mintId)
      await expect(dstAmount).to.be.equal(mintAmount)
    })
  })
})