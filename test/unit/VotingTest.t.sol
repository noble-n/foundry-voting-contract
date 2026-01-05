// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Voting} from "src/Voting.sol";
import {DeployVoting} from "script/DeployVoting.s.sol";

contract VotingTest is Test {
    Voting public voting;

    address USER = makeAddr("user");

    function setUp() external {
        uint256 startTime = block.timestamp + 3;
        uint256 endTime = block.timestamp + 6;
        voting = new Voting(startTime, endTime); // Deploy directly
    }

    function testOwnerIsMsgSender() public view{
        assertEq(voting.getOwner(), address(this));
    }

    function testVotingRevertsWithInvalidTimeFrame() public {
        vm.expectRevert(Voting.Voting__InvalidTimeframe.selector);
        new Voting(block.timestamp + 3600, block.timestamp);
    }

    function testOnlyOwnwerCanAddOption() public{
        vm.prank(USER);
        vm.expectRevert(Voting.Voting__NotOwner.selector);
        voting.addOption("Noble");
    }

    function testOwnerCanAddOption() public{
        voting.addOption("James");
    }

    function testOwnerCannotAddOptionAfterVotingHasStarted() public {
        vm.warp(block.timestamp + 5);
        vm.expectRevert(Voting.Voting__VotingAlreadyStarted.selector);
        voting.addOption("John");
    }

    function testVotingRevertsWhenVotingHasNotStarted() public {
        voting.addOption("John");

        bytes32 optionId = voting.getOptions()[0].id;
        vm.warp(block.timestamp - 1);
        vm.expectRevert(Voting.Voting__VotingNotStarted.selector);
        voting.castVote(optionId);
    }

    function testVotingRevertsWhenVotingHasClosed() public {
        voting.addOption("John");

        bytes32 optionId = voting.getOptions()[0].id;
        vm.warp(block.timestamp + 10);
        vm.expectRevert(Voting.Voting__VotingClosed.selector);
        voting.castVote(optionId);
    }

    function testVotingRevertsWhenUserAlreadyVoted() public{
        voting.addOption("John");

        bytes32 optionId = voting.getOptions()[0].id;
        vm.warp(block.timestamp + 3);
        voting.castVote(optionId);
        vm.expectRevert(Voting.Voting__AlreadyVoted.selector);
        voting.castVote(optionId);
    }

    function testOptionsSave() public {
        voting.addOption("John");

        Voting.Option[] memory options = voting.getOptions();

        assertEq(options.length, 1);
        assertEq(options[0].name, "John");
        assertTrue(options[0].id != bytes32(0));
    }

    function testGetVotes() public {
        voting.addOption("John");
        bytes32 optionId = voting.getOptions()[0].id;
        vm.warp(block.timestamp + 3);
        voting.castVote(optionId);

        uint256 votes = voting.getVotes(optionId);

        assertTrue(votes > 0 );

    }

    function testGetNumOfOptions() public {
        voting.addOption("John");
        vm.warp(block.timestamp + 3);

        uint256 numOfOptions = voting.getNumOptions();

        assertTrue(numOfOptions > 0 );

    }

}
 
