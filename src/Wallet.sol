// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Wallet {
    address payable public owner;

    event Withdraw(address indexed from, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier isOwner() {
        require(msg.sender == owner, "No owner");
        _;
    }
        
    fallback() external payable {}

    receive() external payable {}

    function withdraw(uint256 amount) public isOwner {
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(address(this), amount);
    }

    function transfer(address recipient, uint256 amount) public isOwner {
        require(recipient != address(0));
        (bool success,) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        emit Transfer(address(this), recipient, amount);
    }
}
