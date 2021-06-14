const Token = artifacts.require('Token');
const StakingContract = artifacts.require('StakingContract');

module.exports = async function(deployer) {
  await deployer.deploy(Token)
  const token = await Token.deployed()

  await deployer.deploy(StakingContract, token.address)
  const stakingContract = await StakingContract.deployed()

  // change token's minter from deployer to staking contract
  await token.passMinterRole(stakingContract.address)
}