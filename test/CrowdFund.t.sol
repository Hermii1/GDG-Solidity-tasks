// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CrowdFund} from "../src/CrowdFund.sol";

contract CrowdFundTest is Test {
    CrowdFund public crowdFund;
    address public owner;
    address public backer1;
    address public backer2;
    
    uint256 public constant GOAL = 10 ether;
    uint32 public constant DURATION = 7 days;
    
    function setUp() public {
        crowdFund = new CrowdFund();
        owner = address(0x1);
        backer1 = address(0x2);
        backer2 = address(0x3);
        
        vm.deal(backer1, 20 ether);
        vm.deal(backer2, 20 ether);
        
        vm.prank(owner);
        crowdFund.create(GOAL, DURATION);
    }
    
    function test_CreateCampaign() public view {
        (address campaignOwner, uint256 goal, uint256 pledged, uint256 startAt, uint256 endAt, bool claimed) = 
            crowdFund.campaigns(1);
        
        assertEq(campaignOwner, owner);
        assertEq(goal, GOAL);
        assertEq(pledged, 0);
        assertEq(startAt, block.timestamp);
        assertEq(endAt, block.timestamp + DURATION);
        assertEq(claimed, false);
        assertEq(crowdFund.campaignCount(), 1);
    }
    
    function test_Pledge() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 5 ether}(1);
        
        (,, uint256 pledged,,,) = crowdFund.campaigns(1);
        assertEq(pledged, 5 ether);
        assertEq(crowdFund.pledgedAmount(1, backer1), 5 ether);
    }
    
    function test_MultiplePledges() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 3 ether}(1);
        
        vm.prank(backer1);
        crowdFund.pledge{value: 2 ether}(1);
        
        (,, uint256 pledged,,,) = crowdFund.campaigns(1);
        assertEq(pledged, 5 ether);
        assertEq(crowdFund.pledgedAmount(1, backer1), 5 ether);
    }
    
    function test_MultipleBackers() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 5 ether}(1);
        
        vm.prank(backer2);
        crowdFund.pledge{value: 3 ether}(1);
        
        (,, uint256 pledged,,,) = crowdFund.campaigns(1);
        assertEq(pledged, 8 ether);
        assertEq(crowdFund.pledgedAmount(1, backer1), 5 ether);
        assertEq(crowdFund.pledgedAmount(1, backer2), 3 ether);
    }
    
    function test_CannotPledgeAfterEnd() public {
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(backer1);
        vm.expectRevert("Campaign has ended");
        crowdFund.pledge{value: 5 ether}(1);
    }
    
    function test_CannotPledgeZero() public {
        vm.prank(backer1);
        vm.expectRevert("Must pledge more than 0");
        crowdFund.pledge{value: 0}(1);
    }
    
    function test_OwnerCanClaimAfterGoalReached() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 6 ether}(1);
        
        vm.prank(backer2);
        crowdFund.pledge{value: 4 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        uint256 balanceBefore = owner.balance;
        
        vm.prank(owner);
        crowdFund.claim(1);
        
        uint256 balanceAfter = owner.balance;
        
        assertEq(balanceAfter, balanceBefore + 10 ether);
        
        (,,,,, bool claimed) = crowdFund.campaigns(1);
        assertEq(claimed, true);
    }
    
    function test_CannotClaimBeforeEnd() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 10 ether}(1);
        
        vm.prank(owner);
        vm.expectRevert("Campaign not ended");
        crowdFund.claim(1);
    }
    
    function test_CannotClaimIfGoalNotReached() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 5 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(owner);
        vm.expectRevert("Goal not reached");
        crowdFund.claim(1);
    }
    
    function test_OnlyOwnerCanClaim() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 10 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(backer1);
        vm.expectRevert("Not campaign owner");
        crowdFund.claim(1);
    }
    
    function test_CannotClaimTwice() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 10 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(owner);
        crowdFund.claim(1);
        
        vm.prank(owner);
        vm.expectRevert("Already claimed");
        crowdFund.claim(1);
    }
    
    function test_RefundWhenGoalNotReached() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 5 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        uint256 balanceBefore = backer1.balance;
        
        vm.prank(backer1);
        crowdFund.refund(1);
        
        uint256 balanceAfter = backer1.balance;
        
        assertEq(balanceAfter, balanceBefore + 5 ether);
        assertEq(crowdFund.pledgedAmount(1, backer1), 0);
    }
    
    function test_CannotRefundIfGoalReached() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 10 ether}(1);
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(backer1);
        vm.expectRevert("Goal was reached");
        crowdFund.refund(1);
    }
    
    function test_CannotRefundBeforeEnd() public {
        vm.prank(backer1);
        crowdFund.pledge{value: 5 ether}(1);
        
        vm.prank(backer1);
        vm.expectRevert("Campaign not ended");
        crowdFund.refund(1);
    }
    
    function test_CannotRefundIfNoFunds() public {
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(backer1);
        vm.expectRevert("No funds to refund");
        crowdFund.refund(1);
    }
}