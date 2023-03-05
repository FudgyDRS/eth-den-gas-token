// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

contract Vault is Ownable, AccessControlEnumerable {
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  mapping(address => uint256) _balance;
  bytes32 public constant BANK_ROLE = keccak256("BANK_ROLE");
  address _bank;

  event deposit(address account, uint256 amount, uint256 timestamp);
  event withdraw(address account, uint256 amount, uint256 timestamp);

  function SetBank(address bank_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(BANK_ROLE, _bank);
    _bank = bank_;
    grantRole(BANK_ROLE, _bank);
  }

  function Withdraw(uint256 amount_) public onlyRole(BANK_ROLE) {
    require(_balance[tx.origin] > amount_, "Insufficent funds");
    (bool success, ) = payable(tx.origin).call{value: amount_}("");
    require(success);
    emit withdraw(tx.origin, amount_, block.timestamp);
  }

  receive() external payable {
    if(msg.value > 0)
      require(msg.sender == _bank, "Only bank can use vault"); // this will likely change to fully custodial
    _balance[tx.origin] += msg.value;
    emit deposit(tx.origin, msg.value, block.timestamp);
  } // contract can receive ETH 
  fallback() external {} // contract can be sent raw bytecode
}