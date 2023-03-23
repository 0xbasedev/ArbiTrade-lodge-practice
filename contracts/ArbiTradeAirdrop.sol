// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IStakingContract {
    function balanceOf(address account) external view returns (uint256);
    function stakeStartTime(address account) external view returns (uint256);
}

contract ArbiTradeAirdrop {
    address public owner;
    IERC20 public arbiTradeToken;
    IStakingContract public stakingContract;

    struct Airdrop {
        uint256 amount;
        uint256 date;
        bool distributed;
    }

    mapping(uint256 => Airdrop) public airdrops;

    uint256 public airdropReserve;
    uint256 public currentAirdropIndex;

    uint256 public minStakeBalance;
    uint256 public minStakeDuration;

    constructor(address _arbiTradeToken, address _stakingContract, uint256 _minStakeBalance, uint256 _minStakeDuration) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
        stakingContract = IStakingContract(_stakingContract);
        minStakeBalance = _minStakeBalance;
        minStakeDuration = _minStakeDuration;
    }

    function setAirdropSchedule(uint256[] memory amounts, uint256[] memory dates) external onlyOwner {
        require(amounts.length == dates.length, "Invalid airdrop schedule");
        for (uint256 i = 0; i < amounts.length; i++) {
            airdrops[i] = Airdrop(amounts[i], dates[i], false);
            airdropReserve += amounts[i];
        }
    }

    function distributeAirdrop() external {
        require(airdropReserve > 0, "No airdrop available");
        require(currentAirdropIndex < getAirdropCount(), "All airdrops have been distributed");
        Airdrop storage currentAirdrop = airdrops[currentAirdropIndex];
        require(block.timestamp >= currentAirdrop.date, "Airdrop not available yet");
        require(!currentAirdrop.distributed, "Airdrop already distributed");

        for (uint256 i = 0; i < stakingContract.balanceOf(msg.sender); i++) {
            uint256 stakeStartTime = stakingContract.stakeStartTime(msg.sender);
            if (block.timestamp >= stakeStartTime + minStakeDuration * 1 days) {
                uint256 stakeBalance = stakingContract.balanceOf(msg.sender);
                if (stakeBalance >= minStakeBalance) {
                    arbiTradeToken.transfer(msg.sender, currentAirdrop.amount);
                }
            }
        }
        currentAirdrop.distributed = true;
        airdropReserve -= currentAirdrop.amount;
        currentAirdropIndex++;
    }

    function getAirdropCount() public view returns (uint256) {
        return uint256(airdrops.length);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}
