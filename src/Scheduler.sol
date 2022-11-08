// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Scheduler {
 
    error InsufficientBalance(uint256 paymentId, uint256 available, uint256 required);
    error TransactionFailed();

   event PaymentScheduled(uint256 paymentId, address indexed owner, address indexed to, uint256 amount);
    event PaymentExecuted(uint256 paymentId);
    event PaymentDeactivated(uint256 indexed paymentId, address indexed owner); 

    uint256 public paymentId;

    struct Payment {
        uint256 paymentId;
        address owner;
        address to;
        uint256 amount;
        uint8 dayOfMonth;
        uint256 lastExecuted;
        bool active;
    }

    mapping(uint256 => Payment) public scheduledPayments;
    mapping(address => uint256) public fundsDeposited;
    mapping(address => uint256) public balanceOf;

    constructor() {}

    // to do: to be inherited from ERC20 
    receive() external payable{
        balanceOf[msg.sender] += msg.value;
    }

    /// @notice Schedule a recurring payment at any day of the month
    /// @dev The day of the month is not yet converted
    /// @return The id of the scheduled recurring payment
    function schedulePayment(address to, uint256 amount, uint8 dayOfMonth) public returns (uint256) {
        require(dayOfMonth < 30, "dayOfMonth should be smaller than 30");
        paymentId++;
        Payment memory newPayment = Payment({
            paymentId: paymentId,
            owner: msg.sender,
            to: to,
            amount: amount,
            dayOfMonth: dayOfMonth,
            lastExecuted: 0,
            active: true
        });

        emit PaymentScheduled(paymentId, msg.sender, to, amount);
        return paymentId;
    }

    function getPaymentById(uint256 id) public returns (Payment memory) {
        return scheduledPayments[id];
    }

        
    function executePayment(uint256 id) public {
        Payment memory payment = scheduledPayments[id];
        uint256 balanceOfUser = balanceOf[msg.sender];
        require(balanceOfUser > payment.amount, InsufficientBalance(id, balanceOfUser, payment.amount));
        balanceOf[msg.sender] -= payment.amount;
        payment.lastExecuted = now;
        scheduledPayments[id] = payment;
        (bool success, ) = msg.sender.call{value: payment.amount}("");
        require(success, TransactionFailed());
    }

    function deactivatePayment(uint256 id) public {
        scheduledPayments[id].active = false;
        emit PaymentDeactivated(id, msg.sender); 
    }

}
