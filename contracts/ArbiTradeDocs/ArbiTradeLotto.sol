// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ArbiTradeToken.sol";

contract Lottery {
    address public owner;
    ArbiTradeToken public arbiTradeToken;
    uint256 public constant TICKET_PRICE = 100;
    uint256 public constant TICKET_SALE_DURATION = 1 weeks;
    uint256 public constant LOTTERY_DURATION = 1 days;
    uint256 public ticketSaleStartTime;
    uint256 public ticketSaleEndTime;
    uint256 public lotteryEndTime;
    uint256 public totalTicketsSold;
    mapping(address => uint256) public ticketBalances;

    event TicketPurchase(address indexed buyer, uint256 amount);
    event LotteryWinner(address indexed winner, uint256 prize);

    constructor(address tokenAddress) {
        owner = msg.sender;
        arbiTradeToken = ArbiTradeToken(tokenAddress);
        ticketSaleStartTime = block.timestamp;
        ticketSaleEndTime = ticketSaleStartTime + TICKET_SALE_DURATION;
        lotteryEndTime = ticketSaleEndTime + LOTTERY_DURATION;
    }

    function buyTickets(uint256 numTickets) public {
        require(block.timestamp >= ticketSaleStartTime && block.timestamp <= ticketSaleEndTime, "Lottery: Ticket sales closed");
        require(arbiTradeToken.balanceOf(msg.sender) >= numTickets * TICKET_PRICE, "Lottery: Insufficient funds");
        require(totalTicketsSold + numTickets <= arbiTradeToken.totalSupply(), "Lottery: Not enough tickets remaining");

        arbiTradeToken.transferFrom(msg.sender, address(this), numTickets * TICKET_PRICE);
        ticketBalances[msg.sender] += numTickets;
        totalTicketsSold += numTickets;

        emit TicketPurchase(msg.sender, numTickets);
    }

    function endLottery() public {
        require(block.timestamp >= lotteryEndTime, "Lottery: Lottery still ongoing");

        uint256 winningTicket = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase))) % totalTicketsSold;

        address winner;
        uint256 prize;

        for (uint256 i = 0; i < arbiTradeToken.totalSupply(); i++) {
            address ticketHolder = arbiTradeToken.tokenByIndex(i);
            uint256 ticketCount = ticketBalances[ticketHolder];

            if (ticketCount > 0) {
                if (winningTicket < ticketCount) {
                    winner = ticketHolder;
                    prize = ticketCount * TICKET_PRICE;
                    break;
                } else {
                    winningTicket -= ticketCount;
                }
            }
        }

        require(winner != address(0), "Lottery: No winner");

        arbiTradeToken.transfer(winner, prize);

        emit LotteryWinner(winner, prize);

        // Reset lottery state
        totalTicketsSold = 0;
        ticketSaleStartTime = block.timestamp;
        ticketSaleEndTime = ticketSaleStartTime + TICKET_SALE_DURATION;
        lotteryEndTime = ticketSaleEndTime + LOTTERY_DURATION;
    }

    function withdrawTokens(address recipient, uint256 amount) public onlyOwner {
        arbiTradeToken.transfer(recipient, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Lottery: Only owner can call this function");
        _;
    }
}



//This contract sets up a simple lottery game that allows users to purchase tickets using ArbiTrade Token. The buyTickets function allows users to purchase tickets by transferring the appropriate amount of ArbiTrade Token to the contract. The endLottery function randomly selects a winner from the pool of ticket holders and transfers the prize to the winner. The winner is selected using a simple random number generation algorithm that takes into account the number of tickets held by each user. Finally, the withdrawTokens function allows the contract owner to withdraw any ArbiTrade Tokens that have been sent to the contract.

//Overall, this contract would allow the ArbiTrade platform to implement a lottery game that requires users to use ArbiTrade Token to participate.