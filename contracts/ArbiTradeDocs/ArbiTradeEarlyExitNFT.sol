// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ArbiNFT is ERC721 {
    address public owner;
    address public arbiTradeStakingAddress;

    constructor(string memory name, string memory symbol, address stakingAddress) ERC721(name, symbol) {
        owner = msg.sender;
        arbiTradeStakingAddress = stakingAddress;
    }

    function mint(address recipient) public onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(recipient, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "ArbiNFT: Only the NFT owner can burn this NFT");
        _burn(tokenId);
    }

    function exitEarly(uint256 stakeId) public {
        require(ownerOf(stakeId) == msg.sender, "ArbiNFT: Only the NFT owner can exit early from this stake");
        require(IArbiTradeStaking(arbiTradeStakingAddress).canExitEarly(stakeId), "ArbiNFT: Cannot exit early from this stake");
        IArbiTradeStaking(arbiTradeStakingAddress).exitEarly(stakeId);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ArbiNFT: Only owner can call this function");
        _;
    }
}

interface IArbiTradeStaking {
    function canExitEarly(uint256 stakeId) external view returns (bool);
    function exitEarly(uint256 stakeId) external;
}

//This contract implements a simple ERC721 non-fungible token that grants the owner the ability to exit early from a stake. The mint function allows the contract owner to mint new tokens and assign them to a recipient, while the burn function allows token owners to burn their tokens as needed.

//The exitEarly function checks that the sender owns the NFT and that the stake associated with the NFT can be exited early. If the conditions are met, the function calls the exitEarly function on the ArbiTrade staking contract.

//The onlyOwner modifier restricts certain functions to the contract owner, while the IArbiTradeStaking interface defines the external functions required by the contract to interact with the staking contract.

//Overall, this contract would allow the ArbiTrade platform to implement an NFT that grants users the ability to exit early from a stake.
