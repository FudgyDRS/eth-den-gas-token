//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

contract LiquidationEngine is Ownable, AccessControlEnumerable {
  constructor(address gasToken_, address bank_) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  address _gasToken;
  address _bank;
  uint256 _redeemFee;
  bytes32 public constant LIQUIDATOR_ROLE = keccak256("LIQUIDATOR_ROLE");

  event ApplicationForLiquidator(address account, uint256 timestamp);
  event GrantedLiquidator(address account, uint256 timestamp);
  event RevokedLiquidator(address account, uint256 timestamp);

  function ApplyForLiquidator() public {
    require(!hasRole(LIQUIDATOR_ROLE, msg.sender), "Role already set");
    emit ApplicationForLiquidator(msg.sender, block.timestamp);
  }

  function GrantLiquidator(address address_) public {
    require(!hasRole(LIQUIDATOR_ROLE, msg.sender), "Role already set");
    grantRole(LIQUIDATOR_ROLE, address_);
    emit GrantedLiquidator(address_, block.timestamp);
  }

  function RevokeLiquidator(address address_) public {
    require(hasRole(LIQUIDATOR_ROLE, msg.sender), "Role not set");
    revokeRole(LIQUIDATOR_ROLE, address_);
    emit RevokedLiquidator(address_, block.timestamp);
  }

  function TargetedLiquidation(address address_) public payable onlyRole(LIQUIDATOR_ROLE) {
    // get position in question
    // talk to the bank and get the 
    bool success;
    bytes memory message;
    bytes memory payload = abi.encodeWithSignature("TargetedLiquidation(address)", address_);
    (success, message) = Bank.call(payload);
    require(success);
  }

  function Redemption(uint256 amount_) public payable onlyRole(LIQUIDATOR_ROLE) {
      // get position(s) that satisfy the amount to be paid for amount_ at current collateral

  }

  receive() external payable {} // contract can receive ETH 
  fallback() external {} // contract can be sent raw bytecode
}