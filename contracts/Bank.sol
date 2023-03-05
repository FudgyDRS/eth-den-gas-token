//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';
// in the future to comply with SEC regulations access control must be gated to kill fraudulent accounts

interface IGasToken {
  mint(uint256 amount);
}

contract Bank {
  mapping(address => position) _positions;
  mapping(uint256 => address) _nodes; 
  uint256[] _map// A -> B -> C -> ... -> n

  uint256 dTotal;   // total debt currently issued
  uint256 gTotal;   // total gas currently issued
  uint256 cTotal;   // total collateral of accounts
  uint256 aTotal;   // total number of accounts
  uint256 pTotal;   // total number of positions
  /** Fee for minting gas tokens
    *   - when a redemption occurs, the initFee goes up
    *   - when redemptions do not occur, the initFee lowers over time
    *   - should be a function of a cost of doing arbitrage
    */
  uint256 initFee;  // fee for minting gas tokens
  uint256 burnFee;  // fee for burning gas tokens to claim collateral
  uint256 redeemFee; // weird fee similar to RAI redemption

  address headNode;
  address tailNode;

  

  function getIndex(uint256 index_) private returns(uint256 node_) {
    assembly {
      mstore (0, 2)
      node_ := sload(add(keccak256 (0, 32), index_))
    }
  }
  /**
  what if memory locations had some gaps between them
  ID    NODE
  insert    1 -> next 5 are blank -> node3
  insert    2 -> next 0 are blank -> node1

  A000CBD0E0F0G
  A0C00B


  A00C_B_DE0F0G
  A00C0B0DE0F0G
  _00C0B0D?E0F0G
  000C0B0DAEF0G
  000C0BD_A?EFG
  000C0BD0A0EFG

  *4 -> * -> node4
  *3 -> * -> node3
  *2 -> * -> node2
  *1 -> * -> node1

  *6 -> * -> node6 -> node7
  *5 -> * -> node5 -> node6
  insert node2
  *4 -> * -> node4 -> node5
  *3 -> * -> node3 -> node4
  *2 -> * -> _
  *1 -> * -> node1 -> node3

  *6 -> * -> node6 -> node7
  *5 -> * -> node5 -> node6
  *? -> * -> node2 -> node5
  *4 -> * -> node4 -> node2
  *3 -> * -> node3 -> node4.
  *2 -> * -> _
  *1 -> * -> node1 -> node3

  ########????
  ID      NEXT
  ID -> node
  NEXT -> next index
  "stretchy indices"
  and index points to memory location that stores the ID of the node and the distance from the next object
  when we delete a memory location we need the indices to shift to fill the missing data
  if the data at an index is freed everything is supposed to be linked, but there is a gap
  take the lower 128 bits to "stretch" the current index over all non-existing indices
  because the nodes are in random memory their relative indices can be "stretched" apart to "squeeze"
  in a new index linking to the new node

  
  1 -> (*1 -> *2) -> node1
  2 -> (*2 -> *3) -> node2
  3 -> (*3 -> *4) -> node3
  4 -> (*4 -> *5) -> node4
  5 -> (*5 -> *6) -> node5

  1 -> (*1 -> *2) -> node1
  2 -> (*2 -> *3) -> _
  3 -> (*3 -> *4) -> node3
  4 -> (*4 -> *5) -> node4
  5 -> (*5 -> *6) -> node5

  ABCDEFGH
  A_CDEFBGH
  solution: zigzag pattern stored in a memory array add(keccak256(slot), offset)
  
   */

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

  // insert will be done using relative weight, when not applicable binary search tree
  // this function is not ready yet, so use ArtificalCreateAndInsert
  function _Insert(address address_) private returns(uint256) {
    //
    position storage position_ = positions[address_];
    uint256 CR_ = 10000 * position_.collateral / (position_.basefee * position_.debt); // divisor 10000
    // create weight of current solvency
    uint256 weight_ = 150 * dTotal * basefee / cTotal; // weight can be above 1 (significantly overcollateralized vault)
    position memory headNode_ = position(headNode);
    position memory tailNode_ = position(tailNode);
    uint256 headCR_ = 1000 * headNode.collateral / (block.basefee() * headNode_.debt);
    uint256 tailCR_ = 1000 * tailNode.collateral / (block.basefee() * tailNode_.debt);
    uint256 median_ = (headCR_ + tailCR_) / 2;
    // if index > pTotal
  } 

  function Insert(address address_, index_) internal returns(bool) {
    // return _Insert(address_);
    return InsertAt(address_, index_);
    /**
    uint256 collateral;
    uint256 debt;
    uint256 basefee;
    uint256 prevNode;
    uint256 nextNode;
     */

  }

  // known position is assumed to be pushed above in the sorted list
  /**
  somehow you know where to insert where to insert
  you know the head node/tail node
  you know the index of the add
  how do you find the spot that without searching from the tails
  normal hashmap is not one-to-one because index -> node means when the new nodes is squeezed in, 
    we must change all indecies under where it was and all indcies above where it's going to be
  case
  11111 A 00000 B 22222
  
   */
  // n => n+1, n+1
  function InsertAt(address address_, uint256 index_) public payable returns(bool) {
    // insert to position and relink nodes around new position
    position storage position_ = positions[address_];

  }

  // needs to be adjusted for twap later
  /**
    * Example:
    *  time   collateral   debt          value
    *  t0     c: 150 eth   d:  100 eth   v:  100 eth
    *  t1     c: 150 eth   d:  100 eth   v:  150 eth
    *  t2     c: 300 eth   d:  200 eth   v:  250 eth
   */
   // minimum collateral for initating a position
   // motivation: we require a resonable usage of our system since every iteration of search
   //   will directly shift the burden on gas onto the consumer
   uint256 _minCollateral;
  function createPosition() public payable returns(bool) {
    require(msg.value > _initfee, "New collateral <= init");
    uint256 value_ = msg.value - init;
    require(value_ >= _minCollateral)
    
    uint256 mintAmount_ = 150 * value_ / 100;
    position storage position_ = positions[tx.origin];
    if(position_.collateral == 0) {
      // node 1 == null
      position_ = position(value_, issued, issued*block.basefee, 1, 1);
    } else {
      uint256 newcollateral_ = position_.collateral + value_;
      uint256 newdebt_ = position_.debt + mintAmount_;
      uint256 newdebtvalue_ = position_.debt * position_.basefee + 150 * value_ * block.basefee / 100;
      
      // solve for new relative basefee
      // newcollateral_ / newdebtvalue_ = CR = c / (d*b)
      // newdebtvalue_ = newdebt_ * basefee
      uint256 newbasefee_ = newdebtvalue_ / newdebt_;
      position_.collateral = newcollateral_;
      position_.debt = newdebt_;
      position_.basefee = newbasefee_;
    }
    //
    bool success;
    bytes memory message;
    bytes memory payload = abi.encodeWithSignature("mint(uint256,address)", mintAmount_, tx.origin);
    
    // mint gas token
    (success, message) = GasToken.call(payload);
    // safe users collateral in the vault (likely custodially owned by a trusted their party 
    //  with a money transmitter liscense)
    (success, message) = Vault.call{value: value_}("");
    // Service fee for minting, likely will be transmitted to LP to maintain gas pegging
    (success, message) = Treasury.call{value: _initfee}("");

    uint256 issued = msg.value*150/100;
    uint256 cAmount;
    uint256 gAmount;
    uint256 dAmount;
      /**
      add collateral
      mint qi token
      show eth locked is in vault
      deposit to mint, init fee fixed
      withdraw to burn, burn fee fixed
      redeem fee fixed
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
      *
      * Index system is more complicated, a 'stretchy indices' system will likely be used in the future
      */
  }

  receive() external payable {} // contract can receive ETH 
  fallback() external {} // contract can be sent raw bytecode
}