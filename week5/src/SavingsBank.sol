// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

//starting point for the savings bank contract
contract SavingsBank {
    //mapping to store the balance of each user
    mapping (address => uint256) private balances;

    
    //event to log deposits 
    event Deposit(address indexed user, uint256 amount);
    //event to log withdrawals
    event Withdraw(address indexed user, uint256 amount);

    //Deposit ETH into contract
    function deposit() external payable {
        //we want to make sure that the deposit amount is greater than 0, if it's not we will revert the transaction with an error message
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        //when we emit we are doing it to log the event of a deposit, we are logging the sender and the amount deposited
        emit Deposit(msg.sender, msg.value); 
    }
    
    //withdraw ETH from contract
    function withdraw(uint256 amount) external {
    //we want to make sure that the user has enough balance to withdraw, if not we will revert the transaction with an error message
    require(amount > 0, "Withdrawal amount must be greater than 0");
    require(balances[msg.sender] >= amount, "Insufficient balance");

    //we will update the user's balance by subtracting the withdrawal amount
    balances[msg.sender] -= amount;
    //we will transfer the withdrawn amount to the user
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Withdrawal transfer failed");
    //we will emit the Withdraw event to log the withdrawal, we are logging the sender and the amount withdrawn
    emit Withdraw(msg.sender, amount);
    }

    //check balance of the user 
    function getBalance(address user) external view returns (uint256) {
        return balances[user];  
    }

    //fallback function to accept ETH sent directly to the contract
    receive() external payable {
        //we want to make sure that the deposit amount is greater than 0, if it's not we will revert the transaction with an error message
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        //when we emit we are doing it to log the event of a deposit, we are logging the sender and the amount deposited
        emit Deposit(msg.sender, msg.value);
    }
    //get total ETH stored in the contract
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

}