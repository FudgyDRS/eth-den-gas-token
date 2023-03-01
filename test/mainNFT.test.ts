import { assert, expect } from "chai";
import { artifacts, contract, ethers } from "hardhat";
import { BN, constants, expectEvent, expectRevert, ether, time, balance, send } from "@openzeppelin/test-helpers";
import { parseEther, formatUnits, parseUnits } from "ethers/lib/utils";
import { transferableAbortController } from "util";
import { Overrides } from "ethers/lib/ethers";
//import { time } from "@nomicfoundation/hardhat-network-helpers";

const MainGame = artifacts.require("MainGame");
const MainNFT = artifacts.require("MainNFT");
const MainToken = artifacts.require("MainToken");
//console.log("artifacts:", MainNFT.toJSON())

let mainNFT;
let mainToken;
let mainGame;

contract("Main NFT", ([owner, operator, ...users]) => {
  
  let baseURI;
  let tokenURI;
  
  let maxSupply, totalSupply;

  let startTimestamp;
  let maxPerAddress;
  let maxPerTransaction;

  let beforeBalance, beforeBalanceOwner;
  let changedBalance, changedBalanceOwner;

  let _balance;
  let div10 = "10000000000";
  let div18 = "100000000000000000";
  let div10bn = BN(div10);
  let div18bn = BN(div18);


  before(async () => {
    mainNFT = await MainNFT.new("PoP NFT", "POPNFT", { from: owner });
    mainToken = await MainToken.new("PoP Token", "POPTKN", { from: owner });
    mainGame = await MainGame.new(mainNFT.contract._address, mainToken.contract._address, { from: owner });

    await mainToken.grantMint(mainGame.contract._address, { from: owner });
  });

  describe("#1 - Test normal NFT functions", async () => {
    it("Admin Mint", async () => {

      /* Mint to users[0] */
      let totalSupply = (await mainNFT.totalSupply({ from: owner })).toString();
      //console.log("totalSupply: ", totalSupply)

      await mainNFT.mint(users[0], totalSupply);
      totalSupply = (await mainNFT.totalSupply({ from: owner })).toString();
      //console.log("totalSupply: ", totalSupply)

      let balance = (await mainNFT.balanceOf(users[0], { from: owner })).toString();
      expect((await mainNFT.totalSupply({ from: owner })).toString()).to.equal(balance);
      //console.log("totalSupply: ", totalSupply)

      await expectRevert(mainNFT.methods['mint(address,uint256)']
        .sendTransaction(users[0], totalSupply, { from: users[0] }), 'Ownable: caller is not the owner');

      /* Mint to owner*/
      await mainNFT.mint(owner, totalSupply);
      totalSupply = (await mainNFT.totalSupply({ from: owner })).toString();
    });

    it("Normal Mint", async () => {
      await mainNFT.methods["mint()"]
        .sendTransaction({ from: users[0] })

      let balance = (await mainNFT.balanceOf(users[0], { from: users[0] })).toString();
      expect(2).to.equal(parseInt(balance));
    });

    it("Burn", async () => {
      await mainNFT.burn(1, { from: owner });
      await expectRevert(mainNFT.burn(1, { from: owner }), "ERC721: invalid token ID");
      await expectRevert(mainNFT.burn(0, { from: owner }), "ERC721: caller is not token owner or approved");
      await mainNFT.burn(0, { from: users[0] });
    });

    /* it("TransferFrom", async () => {
      let totalSupply = await mainNFT.totalSupply({ from: owner })
      await mainNFT.mint({ from: users[0] });
      let balance = formatUnits(await mainNFT.balanceOf(owner, { from: users[0] }), 0);
      expect("1" == balance)

      expectRevert(await mainNFT.transferFrom(users[0], users[1], totalSupply, { from: owner}), "ERC721: caller is not token owner or approved");
      await mainNFT.transferFrom(users[0], users[1], totalSupply, { from: users[0]});
      await mainNFT.ownerOf(totalSupply, { from: users[0] });
      expect(users[1] == await mainNFT.ownerOf(totalSupply, { from: users[0] }));
    }); */
  });

  /* describe("#2 - Test normal token functions", async () => {
    it("Mint", async () => {
      expectRevert(await mainNFT.mint(users[0], 20000, { from: users[0] }), "Ownable: caller is not the owner");
      mainNFT.mint(users[0], 20000, { from: owner })
      
      let balance = formatUnits(await mainToken.balanceOf(users[0], { from: users[0] }))
      expect(balance == "20000")
    });

    it("Burn", async () => {
      expectRevert(await mainNFT.burn(20000, { from: owner }), "ERC20: burn amount exceeds balance");
      await mainNFT.burn(10000, { from: users[0] })

      let balance = formatUnits(await mainToken.balanceOf(users[0], { from: users[0] }))
      expect(balance == "10000")
    });

    it("TransferFrom", async () => {
      expectRevert(await mainNFT.transferFrom(users[0], users[1], 10000, { from: owner }), "ERC20: insufficient allowance");
      await mainNFT.transferFrom(users[0], users[1], 10000, { from: users[0] })

      let balance = formatUnits(await mainToken.balanceOf(users[0], { from: users[0] }))
      expect(balance == "0")

      balance = formatUnits(await mainToken.balanceOf(users[0], { from: users[1] }))
      expect(balance == "10000")
    });
  });

  describe("#3 - Test game contract", async () => {
    it("Playing the game", async () => {
      await mainNFT.mint({ from: users[0] });
      await mainNFT.mint({ from: users[0] });
    });

    it("Making claims", async () => {
    });
  }); */
});
