import { expect } from "chai";
import { Signer } from "@ethersproject/abstract-signer";
import hre = require("hardhat");
import { SimpleSoulbound } from "../typechain";

const { ethers, network,  deployments } = hre;
const TOKEN_ID = "83653301891184277907742876661250188048444430330866967253545566047795365375447";
const OWNER_ADDRESS = "0x1d60C34f508BbBd7f1cb50b375c4CdD25e718D1c";

describe("Basic SC test", function () {
  this.timeout(0);
  let soulbound: SimpleSoulbound;
  let ensHolder: Signer;
  before("tests", async () => {
    await deployments.fixture();

    const soulbondAddress = (await deployments.get("SimpleSoulbound")).address;
    soulbound = (await ethers.getContractAt("SimpleSoulbound", soulbondAddress)) as SimpleSoulbound;

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [OWNER_ADDRESS],
    });

    ensHolder = await ethers.provider.getSigner(OWNER_ADDRESS);
  })
  it("test ERC721Soulbound", async () => {
    const [signer] = await ethers.getSigners();
    await signer.sendTransaction({to: OWNER_ADDRESS, value: ethers.utils.parseEther("10")});

    // must burn exactly 1 wei to soulbound
    await expect(soulbound.connect(ensHolder).soulbond(TOKEN_ID, "0x01")).to.be.revertedWith("SimpleSoulbound: you must burn one wei to bond your soul");
    await expect(soulbound.connect(ensHolder).soulbond(TOKEN_ID, "0x01", {value: 2})).to.be.revertedWith("SimpleSoulbound: you must burn one wei to bond your soul");
    
    // only bonded token owner can soulbound
    await expect(soulbound.soulbond(TOKEN_ID, "0x01", {value: 1})).to.be.revertedWith("ERC721Soulbound: claimant not owner of bondedTokenId");
    await soulbound.connect(ensHolder).soulbond(TOKEN_ID, "0x01", {value: 1});
    expect(await soulbound.ownerOf(1)).to.equal(OWNER_ADDRESS);

    // token owner transfers to someone else
    await soulbound.connect(ensHolder)["safeTransferFrom(address,address,uint256)"](OWNER_ADDRESS, await signer.getAddress(), 1);
    expect(await soulbound.ownerOf(1)).to.equal(await signer.getAddress());

    // bonded token owner can reclaim at any time
    await expect(soulbound.reclaim(await signer.getAddress(), 1)).to.be.revertedWith("ERC721Soulbound: claimant not owner of bondedTokenId");

    await soulbound.reclaim(OWNER_ADDRESS, 1);
    expect(await soulbound.ownerOf(1)).to.equal(OWNER_ADDRESS);
  });
});