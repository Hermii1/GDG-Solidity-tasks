// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {OwnerMessageBoard} from "../src/OwnerMessageBoard.sol";

contract OwnerMessageBoardTest is Test {
    OwnerMessageBoard public messageBoard;
    address public owner;
    address public nonOwner;
    
    function setUp() public {
        owner = address(0x1);
        nonOwner = address(0x2);
        
        vm.prank(owner);
        messageBoard = new OwnerMessageBoard("Initial Message");
    }
    
    function test_OwnerCanUpdate() public {
        vm.prank(owner);
        messageBoard.updateMessage("New Message");
        
        assertEq(messageBoard.getMessage(), "New Message");
    }
    
    function test_NonOwnerCannotUpdate() public {
        vm.prank(nonOwner);
        vm.expectRevert("Only owner can update message");
        messageBoard.updateMessage("Hacked Message");
        
        assertEq(messageBoard.getMessage(), "Initial Message");
    }
    
    function test_EventEmittedCorrectly() public {
        vm.prank(owner);
        // Expect the event from the contract
        vm.expectEmit(true, false, false, true);
        emit OwnerMessageBoard.MessageUpdated("Updated Message", owner);
        messageBoard.updateMessage("Updated Message");
        
        assertEq(messageBoard.getMessage(), "Updated Message");
    }
    
    function test_OwnerSetCorrectly() public {
        assertEq(messageBoard.owner(), owner);
    }
}
