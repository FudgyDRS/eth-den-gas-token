//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

contract Treasury is Ownable, AccessControlEnumerable {
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function withdraw(address to_) public onlyRole(DEFAULT_ADMIN_ROLE) {
    (bool success, ) = payable(to_).call{value: address(this).balance}("");
    require(success);
  }

  receive() external payable {} // contract can receive ETH 
  fallback() external {} // contract can be sent raw bytecode
}