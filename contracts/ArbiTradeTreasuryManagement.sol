// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeTreasury {
    address public owner;
    IERC20 public arbiTradeToken;

    event FundsDeposited(uint256 amount);
    event FundsWithdrawn(uint256 amount);

    constructor(address _arbiTradeToken) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
    }

    function depositFunds(uint256 amount) external {
        arbiTradeToken.transferFrom(msg.sender, address(this), amount);
        emit FundsDeposited(amount);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        arbiTradeToken.transfer(owner, amount);
        emit FundsWithdrawn(amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}





//The ArbiTradeTreasury contract implements the following functions:

//depositFunds: This function allows users to deposit ArbiTrade tokens into the treasury.

//withdrawFunds: This function allows the owner of the contract to withdraw ArbiTrade tokens from the treasury.

//FundsDeposited: This event is emitted when funds are deposited into the treasury.

//FundsWithdrawn: This event is emitted when funds are withdrawn from the treasury.

//By implementing a treasury management contract, ArbiTrade ensures that it has a secure and centralized location to store its funds. This allows for easier management and distribution of funds, as well as ensuring that funds are kept secure and protected. Overall, the ArbiTrade Treasury Management Contract helps to create a more stable and secure protocol.