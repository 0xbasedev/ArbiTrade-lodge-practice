// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeTreasury {
    address public owner;
    IERC20 public arbiTradeToken;
    uint256 public constant REVENUE_SHARE = 20; // 20% of transaction fees go to the treasury

    constructor(address _arbiTradeToken) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= arbiTradeToken.balanceOf(address(this)), "Insufficient balance");
        arbiTradeToken.transfer(owner, amount);
    }

    function getBalance() external view returns (uint256) {
        return arbiTradeToken.balanceOf(address(this));
    }

    function receiveRevenue(uint256 amount) external {
        uint256 fee = (amount * REVENUE_SHARE) / 100;
        arbiTradeToken.transferFrom(msg.sender, address(this), fee);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}


//The ArbiTradeTreasury contract implements the following functions:

//withdraw: This function allows the contract owner to withdraw excess ArbiTrade tokens from the treasury contract.

//getBalance: This function returns the current balance of ArbiTrade tokens held by the treasury contract.

//receiveRevenue: This function allows the treasury contract to receive transaction fees, with 20% of the fees being transferred to the treasury contract and the remaining 80% being transferred to the recipient of the transaction.

//onlyOwner: This modifier ensures that only the contract owner can access certain functions, such as withdrawing excess tokens from the contract.

//By implementing a treasury contract, ArbiTrade ensures that transaction fees are collected and distributed in a transparent and sustainable manner. The revenue sharing feature ensures that a portion of the fees go to the treasury contract, which can be used to fund future development and maintenance of the protocol. The ability for the contract owner to withdraw excess tokens from the contract ensures that the treasury remains manageable and sustainable over the long term.