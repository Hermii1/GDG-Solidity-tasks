// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PersonalCounter {
    mapping(address => uint256) private counters;
    
    function increment() public {
        counters[msg.sender]++;
    }
    
    function reset() public {
        counters[msg.sender] = 0;
    }
    
    function getCounter(address _user) public view returns (uint256) {
        return counters[_user];
    }
}
