// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";

contract SimpleVaultTest is Test {
    SimpleVault public vault;
    address public user1;
    address public user2;
    
    function setUp() public {
        vault = new SimpleVault();
        user1 = address(0x1);
        user2 = address(0x2);
        
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }
    
    function test_DepositUpdatesBalance() public {
        vm.prank(user1);
        vault.deposit{value: 1 ether}();
        
        assertEq(vault.getBalance(user1), 1 ether);
        assertEq(vault.getContractBalance(), 1 ether);
    }
    
    function test_WithdrawTransfersETH() public {
        vm.prank(user1);
        vault.deposit{value: 1 ether}();
        
        uint256 balanceBefore = user1.balance;
        
        vm.prank(user1);
        vault.withdraw();
        
        uint256 balanceAfter = user1.balance;
        
        assertEq(balanceAfter, balanceBefore + 1 ether);
        assertEq(vault.getBalance(user1), 0);
        assertEq(vault.getContractBalance(), 0);
    }
    
    function test_WithdrawWithoutBalanceReverts() public {
        vm.prank(user1);
        vm.expectRevert("No balance to withdraw");
        vault.withdraw();
    }
}
