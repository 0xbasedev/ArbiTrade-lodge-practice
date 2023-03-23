
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./ArbiTradeToken.sol";

contract SpinTheWheel is VRFConsumerBase {
    bytes32 public keyHash;
    uint256 public fee;
    ArbiTradeToken public arbiTradeToken;
    uint256 public constant SPIN_COST = 100;
    uint256 public constant MAX_SPIN_RESULT = 100;
    mapping(address => bool) public hasSpun;

    event Spin(address indexed player, uint256 result);

    constructor(address vrfCoordinator, address linkToken, bytes32 _keyHash, uint256 _fee, address tokenAddress)
        VRFConsumerBase(vrfCoordinator, linkToken)
    {
        keyHash = _keyHash;
        fee = _fee;
        arbiTradeToken = ArbiTradeToken(tokenAddress);
    }

    function spin() public {
        require(arbiTradeToken.balanceOf(msg.sender) >= SPIN_COST, "SpinTheWheel: Insufficient funds");
        require(!hasSpun[msg.sender], "SpinTheWheel: Already spun");

        arbiTradeToken.transferFrom(msg.sender, address(this), SPIN_COST);
        bytes32 requestId = requestRandomness(keyHash, fee);
        hasSpun[msg.sender] = true;

        emit Spin(msg.sender, uint256(requestId) % MAX_SPIN_RESULT);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // Do nothing - this function is required by Chainlink
    }

    function withdrawTokens(address recipient, uint256 amount) public onlyOwner {
        arbiTradeToken.transfer(recipient, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "SpinTheWheel: Only owner can call this function");
        _;
    }
}

//The spin function allows users to spin the wheel by paying the SPIN_COST fee in ArbiTrade Token. The function first checks that the user has sufficient funds and hasn't already spun, then transfers the fee to the contract and generates a random number using Chainlink's VRF oracle. The random number is then emitted as an event to notify users of their spin result.

//The fulfillRandomness function is required by Chainlink and is left empty in this example, as we don't need to do anything with the random number after it's generated.

//Finally, the withdrawTokens function allows the contract owner to withdraw any ArbiTrade Tokens that have been sent to the contract.

//Overall, this contract would allow the ArbiTrade platform to implement a game of spin the wheel that uses Chainlink for a random spin and requires users to use ArbiTrade Token to play.