// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
  address public minter;

  event MinterChanged(address indexed from, address to);

  constructor() ERC20("My Token","MTK") {
    minter = msg.sender;
  }

  function passMinterRole(address stakingContract) public onlyOwner() {
    minter = stakingContract;
        
    emit MinterChanged(msg.sender, stakingContract);
  }

  function mint(address account, uint256 amount) public onlyOwner() {
    _mint(account, amount);
  }
}