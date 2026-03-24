// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVault {
    mapping(address => uint256) private balances;
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit some ETH");
        balances[msg.sender] += msg.value;
    }
    
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance to withdraw");
        
        balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");
    }
    
    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
