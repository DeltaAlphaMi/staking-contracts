// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./Token.sol";

contract StakingContract {
  
  Token private token;

  mapping(address => uint256) public etherBalanceOf;
  mapping(address => uint256) public depositStart;
  mapping(address => bool) public isDeposited;

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

  constructor(Token token_) {
    token = token_;
  }

  /**
   * @notice Transfers an amount of ETH from the msg.sender to this contract if the sender has not 
   * deposited before and the amount is greater than 0.01 ETH.
   * @dev This function checks if the sender has already made a deposit, and the deposit value is
   * greater than 0.01 ETH. If so, increases the sender's "etherBalanceOf" with the "value" being send,
   * make the sender's status isDeposited "true" and records thh current block timestamp to a mapping.
   * It also emits an event which has three (3) params, msg.sender, msg.value, and block.timestamp.  
   */
  function deposit() public payable {
    // Checks if the user has made a deposit already
    require(isDeposited[msg.sender] == false, "Deposit already active");
    // Checks if the value being sent is greater than 0.01
    require(msg.value >= 1e16, "Deposit must be greater than 0.01 ETH");

    // Changes the mapping values for the user
    etherBalanceOf[msg.sender] += msg.value;
    isDeposited[msg.sender] = true;
    depositStart[msg.sender] += block.timestamp;

    emit Deposit(msg.sender, msg.value, block.timestamp);
  }

  /**
   * @notice Withdraws the amount of ETH that has been deposited by the user,
   * and collects the reward in the new "token".
   * @dev This function calculates the interest based on a 10% APY(annual percentage yield)
   * and returns the whole amount to the user.
   */
  function withdraw() public {
    require(isDeposited[msg.sender] == true, "No previous deposit");
    
    uint userBalance = etherBalanceOf[msg.sender];

    // Calculates the time being passed since the user's deposit
    uint depositTime = block.timestamp - depositStart[msg.sender];

    // 31668017 is calculated as the interest (10% APY) for the minimum deposit amount(0.01 ETH) by:
    // 1e15(10% of 0.01 ETH) / 31577600 (seconds in 365.25 days in a year)
    
    // (etherBalanceOf[msg.sender] / 1e16) is the calculation of how much higher interest will be,
    // based on the deposit amount, e.g. :
    // for (0.01 ETH) we got 0.01 / 1e16 = 1
    // for (0.05 ETH) we got 0.05 / 1e16 = 5 etc
    uint interestPerSecond = 31668017 * (etherBalanceOf[msg.sender] / 1e16);
    uint interest = interestPerSecond * depositTime;

    // Sends funds back to the user
    payable(msg.sender).transfer(userBalance); // ether which has been deposited
    token.mint(msg.sender, interest); // interest which is the profit

    // Resets all mapping values
    etherBalanceOf[msg.sender] = 0;
    depositStart[msg.sender] = 0;
    isDeposited[msg.sender] = false;
    
    emit Withdraw(msg.sender, userBalance, depositTime, interest);
  }
}
