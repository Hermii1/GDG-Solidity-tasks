// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CrowdFund} from "../src/CrowdFund.sol";

contract CrowdFundScript is Script {
    CrowdFund public crowdFund;
    
    function setUp() public {}
    
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();
        
        // Deploy the CrowdFund contract
        crowdFund = new CrowdFund();
        
        console.log("CrowdFund deployed to:", address(crowdFund));
        
        // Create a sample campaign
        // Goal: 10 ETH, Duration: 7 days
        uint256 goal = 10 ether;
        uint32 duration = 7 days;
        
        crowdFund.create(goal, duration);
        
        console.log("Campaign created with ID: 1");
        console.log("Goal:", goal);
        console.log("Duration:", duration, "seconds");
        
        vm.stopBroadcast();
    }
}