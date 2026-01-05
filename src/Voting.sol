// LAYOUT OF CONTRACT:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title Voting Contract
 * @author Nwabuike Noble
 * @notice This contract allows an owner to create voting options and enables users to cast a single vote.
 * @dev Designed for a simple on-chain voting system with owner-controlled setup and public participation.
 */

contract Voting {
     /* ERRORS */
    error Voting__NotOwner();
    error Voting__AlreadyVoted();
    error Voting__InvalidOption();
    error Voting__VotingClosed();
    error Voting__VotingNotStarted();
    error Voting__InvalidTimeframe();
    error Voting__VotingAlreadyStarted();

    // STATE VARIABLES
    address private immutable i_owner;

    struct Option {
        string name;
        bytes32 id;   
        bool exists;
    }

    Option[] private options;
    mapping(bytes32 => uint256) public votes; 

    mapping(address => bool) public hasVoted;
    uint256 public immutable i_startTime;
    uint256 public immutable i_endTime;

    // EVENTS
    event VoteCast(address indexed voter, bytes32 indexed optionId);
    event OptionAdded(string indexed name, bytes32 indexed optionId);

    
    constructor(uint256 _startTime, uint256 _endTime){
        i_owner = msg.sender;

        if(_startTime < block.timestamp) {
            revert Voting__InvalidTimeframe();
        }
        
        if(_endTime <= _startTime) {
            revert Voting__InvalidTimeframe();
        }

        i_startTime = _startTime;
        i_endTime = _endTime;
    }


    // MODIFIERS
    modifier onlyOwner(){
        if (msg.sender != i_owner) revert Voting__NotOwner();
        _;
    }


    /* EXTERNAL FUNCTIONS */

    /// @notice Add a new voting option (only before voting starts)
    function addOption(string memory _name) external onlyOwner {
        if(block.timestamp > i_startTime){
            revert Voting__VotingAlreadyStarted();
        }

        bytes32 optionId = keccak256(abi.encodePacked(_name, options.length));
        options.push(Option({name: _name, id: optionId, exists: true}));

        emit OptionAdded(_name, optionId);
    }

    /// @notice Cast a vote for a given option by ID
    function castVote(bytes32 optionId) external {
        if(block.timestamp < i_startTime){
            revert Voting__VotingNotStarted();
        }

        if(block.timestamp > i_endTime){
            revert Voting__VotingClosed();
        }

        if(hasVoted[msg.sender]){
            revert Voting__AlreadyVoted();
        }

        bool valid = false;
        for (uint256 i = 0; i < options.length; i++) {
            if(options[i].id == optionId && options[i].exists){
                valid = true;
                break;
            }
        }

        if(!valid){
            revert Voting__InvalidOption();
        }

        votes[optionId] += 1;
        hasVoted[msg.sender] = true;

        emit VoteCast(msg.sender, optionId);
        
    }

    /* VIEW FUNCTIONS */

    /// @notice Get all options with their IDs
    function getOptions() external view returns (Option[] memory) {
        return options;
    }

    /// @notice Get the vote count for a given option ID
    function getVotes(bytes32 optionId) external view returns (uint256) {
        return votes[optionId];
    }

    /// @notice Get the number of available options
    function getNumOptions() external view returns (uint256) {
        return options.length;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

}