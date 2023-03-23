// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ArbiNFT is ERC721 {
    address public owner;
    address public arbiTradeTokenAddress;
    uint256 public constant TAX_MULTIPLIER = 0;
    uint256 public constant REWARD_MULTIPLIER = 2;

    constructor(string memory name, string memory symbol, address tokenAddress) ERC721(name, symbol) {
        owner = msg.sender;
        arbiTradeTokenAddress = tokenAddress;
    }

    function mint(address recipient) public onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(recipient, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(ownerOf(tokenId) == msg.sender, "ArbiNFT: Only the NFT owner can transfer this NFT");
        super.transferFrom(from, to, tokenId);
    }

    function getTaxes(uint256 amount) public view returns (uint256) {
        return amount * TAX_MULTIPLIER;
    }

    function getRewards(uint256 amount) public view returns (uint256) {
        return amount * REWARD_MULTIPLIER;
    }

    function transfer(address recipient, uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "ArbiNFT: Only the NFT owner can transfer this NFT");
        super.transfer(recipient, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "ArbiNFT: Only the NFT owner can burn this NFT");
        _burn(tokenId);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ArbiNFT: Only owner can call this function");
        _;
    }
}



//This contract implements a simple ERC721 non-fungible token that grants the owner zero taxes and extra rewards. The mint function allows the contract owner to mint new tokens and assign them to a recipient, while the transferFrom, transfer, and burn functions allow token owners to transfer and burn their tokens as needed.

//The getTaxes and getRewards functions allow the contract to calculate taxes and rewards based on the current multipliers, while the onlyOwner modifier restricts certain functions to the contract owner.

//Overall, this contract would allow the ArbiTrade platform to implement a non-tradable NFT that grants users zero taxes and extra rewards.