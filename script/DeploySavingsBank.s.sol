pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import "../src/SavingsBank.sol";

// Script to deploy the SavingsBank contract to a local blockchain using Foundry's scripting capabilities.
contract DeploySavingsBank is Script {
    function run() external {
        // Start broadcasting transactions to the blockchain. This allows us to interact with the blockchain and deploy contracts.
        vm.startBroadcast();
        // Deploy a new instance of the SavingsBank contract. This will create a new contract on the blockchain that we can interact with.
        new SavingsBank();
        // Stop broadcasting transactions. This ends our interaction with the blockchain for this script.
        vm.stopBroadcast();
    }
}