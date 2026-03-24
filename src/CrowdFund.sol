// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Campaign {
    address owner;
    uint256 goal;
    uint256 pledged;
    uint256 startAt;
    uint256 endAt;
    bool claimed;
}

contract CrowdFund {
    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    function create(uint256 _goal, uint32 _duration) external {
        campaignCount++;

        campaigns[campaignCount] = Campaign({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: block.timestamp,
            endAt: block.timestamp + _duration,
            claimed: false
        });
    }

    function pledge(uint256 _id) external payable {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "Campaign has ended");
        require(msg.value > 0, "Must pledge more than 0");

        campaign.pledged += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.owner, "Not campaign owner");
        require(block.timestamp >= campaign.endAt, "Campaign not ended");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "Already claimed");

        campaign.claimed = true;
        
        (bool success, ) = payable(campaign.owner).call{value: campaign.pledged}("");
        require(success, "Transfer failed");
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.endAt, "Campaign not ended");
        require(campaign.pledged < campaign.goal, "Goal was reached");

        uint256 balance = pledgedAmount[_id][msg.sender];
        require(balance > 0, "No funds to refund");

        pledgedAmount[_id][msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");
    }
}