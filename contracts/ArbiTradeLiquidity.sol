// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router02 {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

contract ArbiTradeLiquidity {
    address public owner;
    address public uniswapRouter;
    IERC20 public arbiTradeToken;

    constructor(address _arbiTradeToken, address _uniswapRouter) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
        uniswapRouter = _uniswapRouter;
    }

    receive() external payable {}

    function addLiquidity() external payable {
        require(msg.value > 0, "Insufficient ETH");
        uint256 tokenAmount = (msg.value * getEthToTokenPrice()) / 10**18;
        arbiTradeToken.transferFrom(owner, address(this), tokenAmount);
        arbiTradeToken.approve(uniswapRouter, tokenAmount);
        IUniswapV2Router02(uniswapRouter).addLiquidityETH{value: msg.value}(
            address(arbiTradeToken),
            tokenAmount,
            0,
            0,
            owner,
            block.timestamp + 3600
        );
    }

    function removeLiquidity(uint256 liquidityAmount) external {
        require(arbiTradeToken.balanceOf(address(this)) >= liquidityAmount, "Insufficient liquidity");
        IERC20(address(this)).approve(uniswapRouter, liquidityAmount);
        (uint256 amountToken, uint256 amountETH,) = IUniswapV2Router02(uniswapRouter).removeLiquidityETH(
            address(arbiTradeToken),
            liquidityAmount,
            0,
            0,
            owner,
            block.timestamp + 3600
        );
        arbiTradeToken.transfer(owner, amountToken);
        payable(owner).transfer(amountETH);
    }

    function getEthToTokenPrice() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = IUniswapV2Router02(uniswapRouter).WETH();
        path[1] = address(arbiTradeToken);
        uint256[] memory amounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(
            msg.value,
            path
        );
        return amounts[1];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}

//The ArbiTradeLiquidity contract implements the following functions:

//addLiquidity: This function allows users to add liquidity to the ArbiTrade token pair on Uniswap by sending ETH and receiving ArbiTrade tokens in exchange.

//removeLiquidity: This function allows users to remove liquidity from the ArbiTrade token pair on Uniswap by sending LP tokens and receiving ArbiTrade tokens and ETH in exchange.

//getEthToTokenPrice: This function calculates the current ETH to ArbiTrade token price on Uniswap.

//onlyOwner: This modifier ensures that only the contract owner can access certain functions, such as adding or removing liquidity.

//By implementing a liquidity provision contract, ArbiTrade ensures that there is sufficient liquidity for trading of the ArbiTrade token on Uniswap. The ability for users to add and remove liquidity from the ArbiTrade token pair on Uniswap enables users to participate in the liquidity provision process and receive rewards for providing liquidity. The getEthToTokenPrice function ensures that users receive a fair exchange rate when adding or removing liquidity. Overall, the ArbiTrade Liquidity Provision Contract helps to ensure the sustainability and stability of the ArbiTrade token market.