// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PersonalCounter} from "../src/PersonalCounter.sol";

contract PersonalCounterTest is Test {
    PersonalCounter public counter;
    address public user1;
    address public user2;
    
    function setUp() public {
        counter = new PersonalCounter();
        user1 = address(0x1);
        user2 = address(0x2);
    }
    
    function test_IncrementWorks() public {
        vm.prank(user1);
        counter.increment();
        assertEq(counter.getCounter(user1), 1);
        
        vm.prank(user1);
        counter.increment();
        assertEq(counter.getCounter(user1), 2);
        
        vm.prank(user2);
        counter.increment();
        assertEq(counter.getCounter(user2), 1);
    }
    
    function test_ResetWorks() public {
        vm.prank(user1);
        counter.increment();
        assertEq(counter.getCounter(user1), 1);
        
        vm.prank(user1);
        counter.reset();
        assertEq(counter.getCounter(user1), 0);
    }
    
    function test_CannotResetAnotherUserCounter() public {
        vm.prank(user1);
        counter.increment();
        assertEq(counter.getCounter(user1), 1);
        
        vm.prank(user2);
        counter.reset();
        
        assertEq(counter.getCounter(user1), 1);
        assertEq(counter.getCounter(user2), 0);
    }
}
