// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma abicoder v2;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./lib/TokenTransferrer.sol";

contract MainToken is ERC20, TokenTransferrer, AccessControlEnumerable {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  address owner;

  constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());
    owner = _msgSender();
  }

  function grantMint(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(MINTER_ROLE, account);
  }

  function revokeMint(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(MINTER_ROLE, account);
  }

  function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(account, amount);
  }

  error WithdrawCouldNotBeProcessed();

  function withdraw() public {
    (bool success,) = owner.call{value: address(this).balance}("");
    if (!success) revert WithdrawCouldNotBeProcessed();
  }

  function ERC20Transfer(address token_, uint256 amount_) public {
    _performERC20Transfer(token_, address(this), owner, amount_);
  }

  function ERC721Transfer(address token_, uint256 tokenId_) public {
    _performERC721Transfer(token_, address(this), owner, tokenId_);
  }

  function ERC1155Transfer(address token_, uint256 tokenId_, uint256 amount_) public {
    _performERC1155Transfer(token_, address(this), owner, tokenId_, amount_);
  }
}
