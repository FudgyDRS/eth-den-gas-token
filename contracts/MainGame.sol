// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./lib/TokenTransferrer.sol";

/**
  * Concept: have x amount of NFTs to access the game where your wallet (not contract) can flip a coin to earn staking power
  * Stipulations: can only flip nft once per day (1 hour)
  * Staking time: claimable once per hour (10 mins)
 */ 
contract MainGame is TokenTransferrer, Ownable {
  uint256 private immutable _day;
  uint256 private immutable _hour;
  address public immutable _nft;
  address public immutable _token;

  uint256 public voteTotal;
  uint256 public dailyAllocation = 6000;

  mapping(uint256 => uint256) public tokenId; // lastused

  error SentFromContract();
  error NotTokenIdOwner();
  error GameCanOnlyOncePerDay();
  error ClaimCouldNotBeProcessed();
  error WithdrawCouldNotBeProcessed();

  struct user {
    uint256 votes;
    uint256 lastClaim;
    uint256 totalClaim;
  }

  mapping(address => user) _user;

  constructor(address nft_, address token_) payable {
    _day = 3600;
    _hour = 600;
    _nft = nft_;
    _token = token_;
  }

  function claim() public {
    uint256 amount = dailyAllocation * _user[msg.sender].votes / voteTotal;
    
    bytes memory payload = abi.encodeWithSignature("mint(address,uint256)", msg.sender, amount);
    (bool success,) = _token.call(payload);
    if (!success) revert ClaimCouldNotBeProcessed();
  }

  // user can techically bypass this function by transfering to a contract the token id of a predicted address then calling the function within the constructor
  // allowing a contract to play the game, letting them win every time
  function game(uint256 tokenId_) public {
    uint256 size;
    assembly {
      size := extcodesize(caller())
    }
    if (size != 0) revert SentFromContract();
    if (IERC721(_nft).ownerOf(tokenId_) != msg.sender) revert NotTokenIdOwner();
    if (block.timestamp - tokenId[tokenId_] < _day) revert GameCanOnlyOncePerDay();

    bytes1 randomish = bytes1(keccak256(abi.encodePacked(msg.sender,block.timestamp,tokenId_)));
    bool success;
    // randomish >> 7 normally has a 1/2 chance of winning
    assembly {
      success := iszero(iszero(shr(randomish,7)))
    }
    tokenId[tokenId_] = block.timestamp;
    if (success) {
      _user[msg.sender].votes++;
      voteTotal++;
    }
  }

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
