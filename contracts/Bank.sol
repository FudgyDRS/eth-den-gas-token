//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';
// in the future to comply with SEC regulations access control must be gated to kill fraudulent accounts

interface IGasToken {
  mint(uint256 amount);
}

contract Bank {
  uint256 dTotal; // total debt currently issued
  uint256 gTotal; // total gas currently issued
  uint256 cTotal; // total collateral of accounts
  uint256 aTotal; // total number of accounts
  uint256 pTotal; // total number of positions
  uint256 initFee; // Fee for minting gas tokens
                    // when a redemption occurs, the initFee goes up
                    // when redemptions do not occur, the initFee lowers over time
                    // should be a function of a cost of doing arbitrage
  uint256 redeemFee; // basically opposite of initFee

  address headNode;
  address tailNode;

  mapping(address => position) positions;

  struct position {
    uint256 collateral;
    uint256 debt;
    uint256 basefee;
    uint256 prevNode;
    uint256 nextNode;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    owner = _msgSender();
  }

  function Insert(address address_) internal returns(uint256) {
    //
    position storage position_ = positions[address_];
    uint256 CR_ = 10000 * position_.collateral / (position_.basefee * position_.debt); // divisor 10000
    // create weight of current solvency
    uint256 weight_ = 150 * dTotal * basefee / cTotal; // weight can be above 1 (significantly overcollateralized vault)
    position memory headNode_ = position(headNode);
    position memory tailNode_ = position(tailNode);
    uint256 headCR_ = 1000 * headNode.collateral / (block.basefee() * headNode_.debt);
    uint256 tailCR_ = 1000 * tailNode.collateral / (block.basefee() * tailNode_.debt);
    uint256 range_ = (headCR_ + tailCR_) / 2;
    // if index > pTotal
  } 

  function createPosition() public payable returns(bool) {
    bool success;
    bytes memory message;
    bytes memory payload = abi.encodeWithSignature("mint(uint256)", mintAmount);
    
    (success, message) = GasToken.call(payload);
    (success, message) = Vault.call{value: msg.sender}("");

    uint256 issued = msg.value*150/100;
    uint256 cAmount;
    uint256 gAmount;
    uint256 dAmount;
    /**
    1 ETH = 150
    T0 1ETH:mint 100DAI
    T1 1ETH:100DAI
    
    100Pgas 1500ETH
    100Pgas == 1000 ETH
    value of Pgas goes up fkd
    value of Pgas goes down good

      */

    // instantaneous CR
    // collateral / (basefee * gas)

    
    positions[tx.origin] = position(msg.value, issued, issued*block.basefee);
    //take the ETH temp
    //send the ETH to the vault
    //mint and then issue Pgas
    //creates the position
    //emit the position
    //emit gas base fee


    /**
      * Data structure will be a doubbly linked list
      * New position entries will be a added to the HEAD of the list
      *
      * A position under collateralized minting more gas tokens to repair their postion
      * must search where to be inserted into the list:
      * pTotal * [150 / (cTotal / (dTotal * basefee))]
      * index = (150 * dTotal * basefee / cTotal) * pTotal
      * if index > pTotal then search for insert from tail/head
      * if index < pTotal then search first indecies around it to, then insert
      */
  }

  function grantMint(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(MINTER_ROLE, account);
  }

  function revokeMint(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(MINTER_ROLE, account);
  }

  receive() external payable {} // contract can receive ETH 
  fallback() external {} // contract can be sent raw bytecode
}