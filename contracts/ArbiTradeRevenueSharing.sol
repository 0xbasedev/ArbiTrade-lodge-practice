// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeRevenueSharing {
    address public owner;
    IERC20 public arbiTradeToken;
    uint256 public constant REVENUE_SHARE_RATE = 10; // 10% revenue share rate

    event RevenueShared(uint256 amount);

    constructor(address _arbiTradeToken) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
    }

    function shareRevenue() external onlyOwner {
        uint256 balance = arbiTradeToken.balanceOf(address(this));
        uint256 revenueShare = (balance * REVENUE_SHARE_RATE) / 100;
        arbiTradeToken.transfer(owner, revenueShare);
        emit RevenueShared(revenueShare);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}


//The ArbiTradeRevenueSharing contract implements the following functions:

//shareRevenue: This function allows the owner of the contract to share a percentage of the contract's ArbiTrade token balance as revenue. The revenue share rate is set to 10%.

//RevenueShared: This event is emitted when revenue is shared.

//By implementing a revenue sharing contract, ArbiTrade ensures that a portion of its profits are distributed to token holders. The 10% revenue share rate helps to ensure that token holders receive a fair share of the protocol's success, while also allowing for the protocol to reinvest the majority of its profits back into the protocol. Overall, the ArbiTrade Revenue Sharing Contract helps to incentivize token holders to hold onto their tokens and participate in the governance of the protocol.