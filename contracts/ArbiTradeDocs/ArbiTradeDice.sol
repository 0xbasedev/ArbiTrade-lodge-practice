// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./ArbiTradeToken.sol";

contract DiceRoll is VRFConsumerBase {
    address public owner;
    ArbiTradeToken public arbiTradeToken;
    bytes32 public requestId;
    uint256 public constant DICE_ROLL_PRICE = 10;
    uint256 public constant DICE_ROLL_PRIZE = 90;
    uint256 public constant MIN_DICE_ROLL = 1;
    uint256 public constant MAX_DICE_ROLL = 6;
    uint256 public constant ROLLING_FEE = 1;
    mapping(address => uint256) public rollingFeeBalances;

    event DiceRolled(address indexed player, uint256 diceRoll, uint256 prize);

    constructor(address tokenAddress, address vrfCoordinator, address linkToken, bytes32 keyHash)
        VRFConsumerBase(vrfCoordinator, linkToken)
    {
        owner = msg.sender;
        arbiTradeToken = ArbiTradeToken(tokenAddress);
        keyHash = keyHash;
    }

    function rollDice(uint256 guess) public {
        require(arbiTradeToken.balanceOf(msg.sender) >= DICE_ROLL_PRICE, "DiceRoll: Insufficient funds");

        requestId = requestRandomness(keyHash, uint256(keccak256(abi.encode(block.timestamp, msg.sender))));
        rollingFeeBalances[msg.sender] += ROLLING_FEE;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 diceRoll = (randomness % MAX_DICE_ROLL) + 1;

        address winner;
        uint256 prize;

        if (diceRoll == guess) {
            winner = msg.sender;
            prize = DICE_ROLL_PRIZE;
        }

        if (winner != address(0)) {
            arbiTradeToken.transfer(winner, prize);
        }

        emit DiceRolled(msg.sender, diceRoll, prize);
    }

    function withdrawTokens(address recipient, uint256 amount) public onlyOwner {
        arbiTradeToken.transfer(recipient, amount);
    }

    function withdrawRollingFees() public {
        require(rollingFeeBalances[msg.sender] > 0, "DiceRoll: No rolling fees to withdraw");

        arbiTradeToken.transfer(msg.sender, rollingFeeBalances[msg.sender]);
        rollingFeeBalances[msg.sender] = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "DiceRoll: Only owner can call this function");
        _;
    }
}



//This contract sets up a simple dice rolling game that allows users to guess a number between 1 and 6 and win a prize if they guess correctly. The rollDice function allows users to roll the dice by submitting a guess and paying the appropriate amount of ArbiTrade Token. The fulfillRandomness function, which is called by the Chainlink VRF oracle, generates a random number between 1 and 6 and determines whether the user has won the prize.

//If the user wins, the contract transfers the prize to the user's account. The withdrawTokens function allows the contract owner to withdraw any ArbiTrade Tokens that have been sent to the contract, while the withdrawRollingFees function allows users to withdraw any rolling fees that they have accumulated.

//Overall, this contract would allow the ArbiTrade platform to implement a simple dice rolling game that uses Chainlink for a random number generation.