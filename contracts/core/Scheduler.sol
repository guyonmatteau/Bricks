// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DataTypes} from 'contracts/libraries/DataTypes.sol';

contract Scheduler {
    error InsufficientBalance(uint256 paymentId, uint256 available, uint256 required);
    error TransactionFailed();

    event PaymentScheduled(uint256 paymentId, address indexed owner, address indexed to, uint256 amount);
    event PaymentExecuted(uint256 paymentId);
    event PaymentDeactivated(uint256 indexed paymentId, address indexed owner);

    uint256 public paymentId;
    address public chainlinkRefContract; 

    mapping(uint256 => DataTypes.RecurringPayment) public scheduledPayments;
    mapping(address => uint256) public balanceOf;

    constructor(
        // address chainlinkRefContract
    ) {
        // chainlinkRefContract = chainlinkRefContract;
        chainlinkRefContract = address(1);

    }

    // to do: to be inherited from ERC20
    receive() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    /// @notice Schedule a recurring payment at any day of the month
    /// @dev The day of the month is not yet converted
    /// @return The id of the scheduled recurring payment
    function schedulePayment(address to, uint256 amount, uint8 dayOfMonth) public returns (uint256) {
        require(dayOfMonth < 30, "dayOfMonth should be smaller than 30");
        paymentId++;
        DataTypes.RecurringPayment memory newPayment = DataTypes.RecurringPayment({
            paymentId: paymentId,
            owner: msg.sender,
            to: to,
            amount: amount,
            dayOfMonth: dayOfMonth,
            lastExecuted: 0,
            active: true
        });
        scheduledPayments[paymentId] = newPayment;
        emit PaymentScheduled(paymentId, msg.sender, to, amount);
        return paymentId;
    }

    function getPaymentById(uint256 id) public view returns (DataTypes.RecurringPayment memory) {
        return scheduledPayments[id];
    }

    function executePayment(uint256 id) public {
        DataTypes.RecurringPayment memory payment = scheduledPayments[id];
        uint256 balanceOfUser = balanceOf[msg.sender];
        require(balanceOfUser > payment.amount, "User does not have sufficient funds");
        balanceOf[msg.sender] -= payment.amount;
        payment.lastExecuted = block.timestamp;
        scheduledPayments[id] = payment;
        (bool success,) = msg.sender.call{value: payment.amount}("");
        require(success, "Transaction Failed");
    }

    function deactivatePayment(uint256 id) public {
        scheduledPayments[id].active = false;
        emit PaymentDeactivated(id, msg.sender);
    }

    /// @notice Swap ETH for required amount USDC
    /// @dev This should do X  
    function swap() internal {}   

    /// @notice Request current WETH/USDC rate needed to determine how much ETH should be swapped
    /// @dev Requires chainlink for external data
    function requestRate() internal {}


}
