// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OwnerMessageBoard {
    address public owner;
    string public message;
    
    event MessageUpdated(string newMessage, address indexed updatedBy);
    
    constructor(string memory _initialMessage) {
        owner = msg.sender;
        message = _initialMessage;
    }
    
    function updateMessage(string memory _newMessage) public {
        require(msg.sender == owner, "Only owner can update message");
        message = _newMessage;
        emit MessageUpdated(_newMessage, msg.sender);
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
}
