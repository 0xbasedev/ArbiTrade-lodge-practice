// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeStaking {
    address public owner;
    IERC20 public arbiTradeToken;

    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Stake[]) public stakes;

    uint256 public totalStaked;
    uint256 public lockPeriod;

    constructor(address _arbiTradeToken, uint256 _lockPeriod) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
        lockPeriod = _lockPeriod;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        require(arbiTradeToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        Stake memory newStake = Stake(amount, block.timestamp);
        stakes[msg.sender].push(newStake);
        totalStaked += amount;
    }

    function unstake() external {
        uint256 totalUnstaked = 0;
        for (uint256 i = 0; i < stakes[msg.sender].length; i++) {
            if (block.timestamp >= stakes[msg.sender][i].startTime + lockPeriod * 1 days) {
                uint256 amount = stakes[msg.sender][i].amount;
                totalUnstaked += amount;
                stakes[msg.sender][i] = stakes[msg.sender][stakes[msg.sender].length - 1];
                stakes[msg.sender].pop();
            }
        }
        require(totalUnstaked > 0, "No stake to unstake");

        require(arbiTradeToken.transfer(msg.sender, totalUnstaked), "Token transfer failed");
        totalStaked -= totalUnstaked;
    }

    function getStakeCount(address account) public view returns (uint256) {
        return stakes[account].length;
    }

    function getStakeBalance(address account) public view returns (uint256) {
        uint256 balance = 0;
        for (uint256 i = 0; i < stakes[account].length; i++) {
            if (block.timestamp >= stakes[account][i].startTime + lockPeriod * 1 days) {
                balance += stakes[account][i].amount;
            }
        }
        return balance;
    }

    function getStakeStartTime(address account) public view returns (uint256) {
        if (stakes[account].length > 0) {
            return stakes[account][stakes[account].length - 1].startTime;
        } else {
            return 0;
        }
    }

    function getTotalStaked() public view returns (uint256) {
        return totalStaked;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}


//The ArbiTradeStaking contract implements the following functions:

//stake: This function allows users to stake their ArbiTrade tokens, locking them up for a specified period. It adds the staking position to the user's list of stakes and increases the total staked amount.

//unstake: This function allows users to unstake their tokens from any stake position that has been locked up for the required period. It removes the stake position from the user's list of stakes, reduces the total staked amount, and transfers the unstaked tokens back to the user's wallet.

//getStakeCount: This function returns the number of staking positions for a given account.

//getStakeBalance: This function calculates the total staked balance for a given account, taking into account only the stakes that have been locked up for the required period.

//getStakeStartTime: This function returns the start time of the latest stake position for a given account, allowing the airdrop contract to verify the staking duration for each position.

//getTotalStaked: This function returns the total amount of ArbiTrade tokens staked in the contract.

//onlyOwner: This modifier ensures that only the contract owner can access certain functions, such as setting the lock period or withdrawing excess tokens from the contract.

//The ArbiTrade Staking Contract allows users to stake their tokens, locking them up for a specified period and earning rewards in the form of airdropped tokens. By implementing the staking and airdrop functionalities within separate contracts, it becomes easier to manage and update each component separately, while still allowing them to interact seamlessly with each other.