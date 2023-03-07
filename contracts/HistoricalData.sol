//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

// Bank - newest hashmap - historical data
// Historical data does not refer to past data rather the history of the 
// interactions with the data.
contract HistoricalData is Ownable, AccessControlEnumerable {
  bytes32 public constant WRITE_ROLE = keccak256("WRITE_ROLE");
  address _bank;
  uint256 public _size;
  // historical data starts at slot 3\

  event RevokedRole(bytes32, address);
  event GrantedRole(bytes32, address);

  error AlreadySet();

  function Insert(bytes32 data_) public payable onlyRole(WRITE_ROLE) {
    assembly {
      let size_ := add(sload(_size.slot), 1)
      let slot_ := add(_size.slot, 0x20)
      calldatacopy(0x40, 0x04, 0x20)
      sstore(add(slot_, mul(size_, 0x20)), data_)
    }
  }

  function GrantWrite(address address_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    grantRole(WRITE_ROLE, address_);
    emit GrantedRole(WRITE_ROLE, address_);
  }

  function RevokeWrite(address address_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(WRITE_ROLE, address_);
    emit RevokedRole(WRITE_ROLE, address_);
  }

  function SetBank(address bank_) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
    if(_bank == bank_) revert AlreadySet();
    RevokeWrite(bank_);
    emit RevokedRole(WRITE_ROLE, bank_);

    _bank = bank_;
    GrantWrite(bank_);
    emit GrantedRole(WRITE_ROLE, bank_);
  }

  constructor(address bank_) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _bank = bank_;
  }
}