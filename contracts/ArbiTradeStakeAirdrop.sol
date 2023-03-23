    function claimAirdrop() external {
        uint256 balance = airdropBalances[msg.sender];
        require(balance > 0, "No balance to claim");
        airdropBalances[msg.sender] = 0;
        totalAirdropped -= balance;
        require(arbiTradeToken.transfer(msg.sender, balance), "Transfer failed");
        emit Airdropped(msg.sender, balance);
    }

    function getAirdropBalance(address staker) external view returns (uint256) {
        return airdropBalances[staker];
    }

    function performAirdrop() external onlyOwner {
        require(block.timestamp >= lastAirdropTime + STAKING_PERIOD, "Airdrop period not over");
        uint256 totalAirdropAmount = (totalStaked * ANNUAL_INTEREST_RATE / 100) / 365 * STAKING_PERIOD + totalAirdropped;
        uint256 airdropAmountPerStaker = totalAirdropAmount / totalStaked;
        for (uint256 i = 0; i < totalStaked; i++) {
            address staker = address(uint160(uint256(keccak256(abi.encodePacked(address(this), i)))));
            uint256 balance = stakers[staker].balance;
            if (balance >= MINIMUM_STAKE) {
                uint256 airdropAmount = balance * airdropAmountPerStaker;
                airdropBalances[staker] += airdropAmount;
                totalAirdropped += airdropAmount;
            }
        }
        lastAirdropTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}



//The ArbiTradeStaking contract implements the following functions:

//stake: This function allows users to stake ArbiTrade tokens in the contract.

//unstake: This function allows users to unstake their ArbiTrade tokens from the contract.

//getStakingDetails: This function allows users to view their staking details, such as their staked balance and the last time they staked and unstaked.

//claimAirdrop: This function allows users to claim their airdropped ArbiTrade tokens.

//getAirdropBalance: This function allows users to view their airdrop balance.

//performAirdrop: This function is called by the owner to perform an airdrop to all stakers who have staked the minimum amount of ArbiTrade tokens. The amount of the airdrop is calculated based on the total staked amount and the annual interest rate, and is distributed evenly among all eligible stakers.

//onlyOwner: This modifier restricts access to certain functions to the contract owner.

//By implementing a staking contract with airdrop functionality, ArbiTrade incentivizes users to stake their ArbiTrade tokens and hold them for a longer period of time. This helps to create a more stable and sustainable protocol by encouraging users to support the project long-term.