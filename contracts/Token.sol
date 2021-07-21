// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Token is ERC20, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor(address minter) ERC20("Token","TKN") {
    _setupRole(MINTER_ROLE, minter);
  }

  /**
   * @notice Allow the minter to mint tokens
   * @param to Address that will receive the minted tokens
   * @param amount Amount of tokens that will be minted
   */
  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(to, amount);
  }
}
