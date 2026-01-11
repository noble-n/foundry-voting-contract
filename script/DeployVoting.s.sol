// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {Voting} from "src/Voting.sol";

contract DeployVoting is Script {
        // function run(uint256 _startTime, uint256 _endTime) external returns (Voting) {

        //     vm.startBroadcast();

        //     // uint256 startTime = block.timestamp + 60;
        //     // uint256 endTime = block.timestamp + 3600;
        //     Voting voting = new Voting(_startTime,_endTime);

        //     vm.stopBroadcast();
        //     return voting;
        // }

     function run() external returns (Voting) {

        vm.startBroadcast();
        // Start in 1 minute (60 seconds)
        uint256 startTime = block.timestamp + 60;
        
        // Last for 2 months (60 days = 60 * 24 * 60 * 60 seconds)
        uint256 endTime = block.timestamp + 60 + (60 * 24 * 60 * 60);
        
        Voting voting = new Voting(startTime,endTime);
        vm.stopBroadcast();
        return voting;
    }
}