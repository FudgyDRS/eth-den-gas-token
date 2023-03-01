// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/TokenTransferrer.sol";

/**
 * @title PoP NFT
 * @notice PoP Exercise Contract
 */
contract MainNFT is ERC721Enumerable, Ownable, ERC721Burnable, TokenTransferrer {
  using SafeERC20 for IERC20;
  using Strings for uint256;

  bool public isLocked;
  string public baseURI;
  uint256 public _maxSupply;

  event Lock();
  event NonFungibleTokenRecovery(address indexed token, uint256 tokenId);
  event TokenRecovery(address indexed token, uint256 amount);
  event WithdrawERC20(address token, address to, uint256 amount);

  error ContractLocked();
  error MaxSupplyReached();
  error TokenIndexDoesNotExist(uint256 tokenId);
  error NotOwnerOrApproved();
  error InputAlreadySet();

  /**
    * @notice Constructor
    * @param _name: NFT name
    * @param _symbol: NFT symbol
    */
  constructor(
      string memory _name,
      string memory _symbol
  ) ERC721(_name, _symbol) {
      _maxSupply = 500;
  }

  /**
    * @notice Allows the owner to lock the contract
    * @param state: toggle lock state
    * @dev Callable by owner
    */
  function lock(bool state) external onlyOwner {
      if(isLocked == state) revert InputAlreadySet();
      isLocked = state;
      emit Lock();
  }

  /**
    * @notice Allows the owner to mint a token to a specific address
    * @param _to: address to receive the token
    * @param _tokenId: tokenId
    * @dev Callable by owner
    */
  function mint(address _to, uint256 _tokenId) external onlyOwner {
      if(totalSupply() >= _maxSupply) revert MaxSupplyReached();
      _mint(_to, _tokenId);
  }

  /**
    * @notice Allows the user to mint a token to self
    */
  function mint() external {
      if(totalSupply() >= _maxSupply) revert MaxSupplyReached();
      _mint(msg.sender, totalSupply());
  }

  /* function totalSupply() public virtual override returns(uint256) {
    return totalSupply();
  } */

  /**
    * @notice Allows the owner to set the base URI to be used for all token IDs
    * @param _uri: base URI (preferably IPFS)
    * @dev Callable by owner
    */
  function setBaseURI(string memory _uri) external onlyOwner {
    if(isLocked) revert ContractLocked();
    baseURI = _uri;
  }

  /**
    * @notice Returns a list of token IDs owned by `user` given a `cursor` and `size` of its token list
    * @param user: address
    * @param cursor: cursor
    * @param size: size
    */
  function tokensOfOwnerBySize(
    address user,
    uint256 cursor,
    uint256 size
  ) external view returns (uint256[] memory, uint256) {
    uint256 length = size;
    if (length > balanceOf(user) - cursor) {
      length = balanceOf(user) - cursor;
    }

    uint256[] memory values = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      values[i] = tokenOfOwnerByIndex(user, cursor + i);
    }

    return (values, cursor + length);
  }

  /**
    * @notice Returns the Uniform Resource Identifier (URI) for a token ID
    * @param tokenId: token ID
    */
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    if(!_exists(tokenId)) revert TokenIndexDoesNotExist(tokenId);

    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override(ERC721, IERC721) {
    //solhint-disable-next-line max-line-length
    if(!_isApprovedOrOwner(_msgSender(), tokenId)) revert NotOwnerOrApproved();
    _transfer(from, to, tokenId);
  }

  function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return
            super.supportsInterface(interfaceId);
    }

  /**
    * @notice fallback only to recieve payments
    */
  receive() external payable { }

  error WithdrawCouldNotBeProcessed();

  function withdraw() public {
    (bool success,) = owner().call{value: address(this).balance}("");
    if (!success) revert WithdrawCouldNotBeProcessed();
  }

  function ERC20Transfer(address token_, uint256 amount_) public {
    _performERC20Transfer(token_, address(this), owner(), amount_);
  }

  function ERC721Transfer(address token_, uint256 tokenId_) public {
    _performERC721Transfer(token_, address(this), owner(), tokenId_);
  }

  function ERC1155Transfer(address token_, uint256 tokenId_, uint256 amount_) public {
    _performERC1155Transfer(token_, address(this), owner(), tokenId_, amount_);
  }
}


