// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbiTradeGovernance {
    address public owner;
    IERC20 public arbiTradeToken;
    uint256 public constant VOTING_PERIOD = 7 days; // 7-day voting period
    uint256 public constant PROPOSAL_THRESHOLD = 10000 * 10**18; // proposal threshold of 10000 ArbiTrade tokens

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 startTime;
        uint256 endTime;
        mapping(address => bool) votes;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => uint256) public votingPower;

    event ProposalCreated(uint256 indexed id, address indexed proposer, string description);
    event ProposalVoted(uint256 indexed id, address indexed voter, bool vote);
    event ProposalExecuted(uint256 indexed id);

    constructor(address _arbiTradeToken) {
        owner = msg.sender;
        arbiTradeToken = IERC20(_arbiTradeToken);
    }

    function createProposal(string memory description) external {
        require(arbiTradeToken.balanceOf(msg.sender) >= PROPOSAL_THRESHOLD, "Insufficient balance");
        uint256 proposalId = proposals.length;
        Proposal memory newProposal = Proposal({
            id: proposalId,
            proposer: msg.sender,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp + VOTING_PERIOD,
            yesVotes: 0,
            noVotes: 0,
            executed: false
        });
        proposals.push(newProposal);
        emit ProposalCreated(proposalId, msg.sender, description);
    }

    function voteProposal(uint256 proposalId, bool vote) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.proposer != address(0), "Invalid proposal");
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting period over");
        require(!proposal.votes[msg.sender], "Already voted");
        uint256 voterPower = votingPower[msg.sender];
        require(voterPower > 0, "Insufficient voting power");
        proposal.votes[msg.sender] = true;
        if (vote) {
            proposal.yesVotes += voterPower;
        } else {
            proposal.noVotes += voterPower;
        }
        emit ProposalVoted(proposalId, msg.sender, vote);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(block.timestamp > proposal.endTime, "Voting period not over");
        uint256 yesVotes = proposal.yesVotes;
        uint256 noVotes = proposal.noVotes;
        uint256 totalVotes = yesVotes + noVotes;
        require(yesVotes > noVotes, "Proposal rejected");
        require(totalVotes >= votingPower[owner] * 2 / 3, "Insufficient quorum");
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
        // execute proposal action here
    }

    function setVotingPower(address user, uint256 power) external onlyOwner {
        votingPower[user] = power;
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized access");
        _;
    }
}



