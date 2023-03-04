//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

contract Treasury {
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    owner = _msgSender();
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