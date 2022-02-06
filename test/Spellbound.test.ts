import { expect } from "chai";
import { Signer } from "@ethersproject/abstract-signer";
import hre = require("hardhat");
import { Spellbound } from "../typechain";

const { ethers, network,  deployments } = hre;
const TOKEN_ID = 334;
const OWNER_ADDRESS = "0x1d60C34f508BbBd7f1cb50b375c4CdD25e718D1c";

describe("Basic SC test", function () {
  this.timeout(0);
  let spellbound: Spellbound;
  let ensHolder: Signer;
  before("tests", async () => {
    await deployments.fixture();

    const soulboundAddress = (await deployments.get("Spellbound")).address;
    spellbound = (await ethers.getContractAt("Spellbound", soulboundAddress)) as Spellbound;

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [OWNER_ADDRESS],
    });

    ensHolder = await ethers.provider.getSigner(OWNER_ADDRESS);
  })
  it("test ERC721Soulbound", async () => {
    const [signer] = await ethers.getSigners();
    await signer.sendTransaction({to: OWNER_ADDRESS, value: ethers.utils.parseEther("10")});

    // must burn exactly 1 wei to spellbound
    await expect(spellbound.connect(ensHolder).mint(TOKEN_ID, ["first line", "second line", "third line"])).to.be.revertedWith("Spellbound: you must burn one wei for spell to be binding");
    await expect(spellbound.connect(ensHolder).mint(TOKEN_ID, ["first line", "second line", "third line"], {value: 2})).to.be.revertedWith("Spellbound: you must burn one wei for spell to be binding");
    
    // only bonded token owner can spellbound
    await expect(spellbound.mint(TOKEN_ID, ["first line", "second line", "third line"], {value: 1})).to.be.revertedWith("ERC721Soulbound: claimant not owner of soulId");
    await spellbound.connect(ensHolder).mint(TOKEN_ID, ["first line", "second line", "third line"], {value: 1});
    expect(await spellbound.ownerOf(1)).to.equal(OWNER_ADDRESS);

    // token owner transfers to someone else
    await spellbound.connect(ensHolder)["safeTransferFrom(address,address,uint256)"](OWNER_ADDRESS, await signer.getAddress(), 1);
    expect(await spellbound.ownerOf(1)).to.equal(await signer.getAddress());

    // bonded token owner can reclaim at any time
    await expect(spellbound.reclaim(await signer.getAddress(), 1)).to.be.revertedWith("ERC721Soulbound: claimant cannot reclaim");

    await spellbound.reclaim(OWNER_ADDRESS, 1);
    expect(await spellbound.ownerOf(1)).to.equal(OWNER_ADDRESS);

    // tokenURI works
    const tokenURI = await spellbound.tokenURI(1);
    expect(tokenURI).to.be.not.null;
  });
});