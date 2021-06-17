// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./Token.sol";

contract StakingContract {
  Token private token;

  struct UserInfo {
    uint256 balance;
    uint256 depositTime;
  }

  uint256 private constant SECONDS_PER_YEAR = 31577600;
  uint256 private annualPercentageYield;

  mapping(address => UserInfo) public userInfo;

  event Deposit(
    address indexed from,
    uint256 amount,
    uint256 timeStart
  );
  event Withdraw(
    address indexed from,
    uint256 amount,
    uint256 depositTime,
    uint256 interest
  );

  constructor(
    Token token_,
    uint256 annualPercentageYield_
  )
  {
    token = token_;
    annualPercentageYield = annualPercentageYield_;
  }

  /**
   * @notice Deposits funds into the Staking Contract
   * @dev This function checks if the user has already made a deposit, and the deposit value 
   * @param amount The amount of ETH being transferred
   */
  function deposit(uint256 amount) public payable {
    require(amount > 0, "Cannot deposit 0");
    token.transferFrom(msg.sender, address(this), amount);    

    UserInfo memory user = userInfo[msg.sender];
    
    user.depositTime = block.timestamp;
    user.balance += amount;

    emit Deposit(msg.sender, amount, block.timestamp);
  }

  /**
   * @notice Withdraws all funds from the Staking Contract
   */
  function withdrawAll() public {
    UserInfo memory user = userInfo[msg.sender];
    require(user.balance > 0, "Cannot withdraw 0");
    
    uint256 currentAmount = user.balance;
    // Calculates the time being passed since the user's deposit
    uint256 timeSinceDeposit = block.timestamp - user.depositTime;

    uint256 interest = calculateMinimumInterest() * timeSinceDeposit;
    uint256 accumulatedAmount = currentAmount + interest;

    // Sends funds back to the user
    token.transfer(msg.sender, accumulatedAmount);

    // Resets all mapping values
    user.balance = 0;
    user.depositTime = 0;
    
    emit Withdraw(msg.sender, accumulatedAmount, timeSinceDeposit, interest);
  }

  function calculateMinimumInterest() public view returns (uint256) {
    return annualPercentageYield / SECONDS_PER_YEAR;
  }
}
