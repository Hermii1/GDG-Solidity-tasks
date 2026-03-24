// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SavingsBank.sol";

// Test contract for SavingsBank
contract SavingsBankTest is Test {
    SavingsBank bank;
// Define test users
    address user1 = address(1);
    address user2 = address(2);

    // Set up the test environment before each test runs by deploying a new instance of the SavingsBank contract and funding the test users with some ether.
    function setUp() public {
        bank = new SavingsBank();
// Fund test users with 10 ether each using the vm.deal function, which allows us to set the balance of an address in the test environment.
// vm is a cheat code provided by Foundry that allows us to manipulate the blockchain state during testing. The deal function is used to set the balance of an address, in this case, we are giving user1 and user2 10 ether each to use in our tests.
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

// Test the deposit function by simulating a deposit from user1 and then checking that the balance of user1 in the bank contract is updated correctly.
    function testDeposit() public {
        // Use vm.prank to simulate a transaction from user1, then call the deposit function with 1 ether. After the deposit, we assert that the balance of user1 in the bank contract is equal to 1 ether.
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
// Assert that the balance of user1 in the bank contract is 1 ether after the deposit.
        assertEq(bank.getBalance(user1), 1 ether);
    }

    // Test that a user cannot withdraw more than their balance by simulating a withdrawal from user1 without making a deposit first. We expect the transaction to revert with an "Insufficient balance" error message.

    function testCannotWithdrawMoreThanBalance() public {
        // Use vm.prank to simulate a transaction from user1, then call the withdraw function with 1 ether. Since user1 has not made any deposits, we expect this transaction to revert with an "Insufficient balance" error message.
        vm.prank(user1);
        // Expect the transaction to revert with the message "Insufficient balance" when user1 tries to withdraw 1 ether without having any balance.
        vm.expectRevert("Insufficient balance");
// Attempt to withdraw 1 ether from user1, which should fail because user1 has not deposited any ether yet.
        bank.withdraw(1 ether);
    }

// Test the withdraw function by simulating a deposit from user1 followed by a withdrawal, and then checking that the balance of user1 in the bank contract is updated correctly.
    function testWithdraw() public {
        // Use vm.startPrank to simulate a series of transactions from user1. First, we call the deposit function with 2 ether, then we call the withdraw function with 1 ether. After these transactions, we assert that the balance of user1 in the bank contract is equal to 1 ether.
        vm.startPrank(user1);
        // Simulate a deposit of 2 ether from user1 to the bank contract.
        bank.deposit{value: 2 ether}();
        // Simulate a withdrawal of 1 ether from user1 to the bank contract.
        bank.withdraw(1 ether);
        // Stop the prank to end the simulation of transactions from user1.
        vm.stopPrank();

        assertEq(bank.getBalance(user1), 1 ether);
    }
// Test the getContractBalance function by simulating deposits from multiple users and then checking that the total balance of the contract is updated correctly.
    function testContractBalance() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        vm.prank(user2);
        bank.deposit{value: 2 ether}();

        assertEq(bank.getContractBalance(), 3 ether);
    }

    // Bonus: multiple users
    function testMultipleUsers() public {
        vm.prank(user1);
        bank.deposit{value: 3 ether}();

        vm.prank(user2);
        bank.deposit{value: 2 ether}();

        vm.prank(user1);
        bank.withdraw(1 ether);

        assertEq(bank.getBalance(user1), 2 ether);
        assertEq(bank.getBalance(user2), 2 ether);
        assertEq(bank.getContractBalance(), 4 ether);
    }
}