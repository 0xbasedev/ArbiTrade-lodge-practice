// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeStaking {
    address public owner;
    IERC20 public arbiTradeToken;
    uint256 public constant REWARD_RATE = 10; // 10% annual reward rate
    uint256 public constant MIN_STAKE_AMOUNT = 1000 * 10**18; // minimum 1000 ArbiTrade tokens required to stake
    uint256 public constant STAKE_LOCK_PERIOD = 30 days; // 30 days stake lock period

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => Stake) public stakes;

    constructor(address _arbiTradeToken) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
    }

    function stake(uint256 amount) external {
        require(amount >= MIN_STAKE_AMOUNT, "Minimum stake amount not met");
        require(arbiTradeToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(stakes[msg.sender].amount == 0, "Already staked");
        arbiTradeToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] = Stake({
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + STAKE_LOCK_PERIOD
        });
    }

    function unstake() external {
        require(stakes[msg.sender].amount > 0, "Not staked");
        require(block.timestamp >= stakes[msg.sender].endTime, "Stake lock period not ended");
        uint256 amount = stakes[msg.sender].amount;
        stakes[msg.sender] = Stake({
            amount: 0,
            startTime: 0,
            endTime: 0
        });
        uint256 reward = (amount * REWARD_RATE) / 365 days * STAKE_LOCK_PERIOD;
        arbiTradeToken.transfer(msg.sender, amount + reward);
    }

    function getStakeDetails(address user) external view returns (uint256, uint256, uint256) {
        Stake memory stake = stakes[user];
        return (stake.amount, stake.startTime, stake.endTime);
    }
}


//The ArbiTradeStaking contract implements the following functions:

//stake: This function allows users to stake their ArbiTrade tokens for a period of 30 days. The minimum stake amount is 1000 ArbiTrade tokens.

//unstake: This function allows users to unstake their ArbiTrade tokens once the stake lock period has ended. Users receive their original stake amount plus a 10% annual reward.

//getStakeDetails: This function returns the details of a user's current stake, including the stake amount, start time, and end time.

//By implementing a staking contract, ArbiTrade incentivizes users to hold onto their tokens and participate in the governance of the protocol. The 30-day stake lock period ensures that users are committed to the success of the protocol over the long term. The 10% annual reward rate helps to encourage users to stake their tokens and receive a reward for their participation. Overall, the ArbiTrade Staking Contract helps to create a sustainable and engaged community of token holders.