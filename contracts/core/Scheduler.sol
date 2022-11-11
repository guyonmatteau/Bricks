// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract Scheduler {
    event PaymentScheduled(uint256 paymentId, address indexed owner, address indexed to, uint256 amount);
    event PaymentExecuted(uint256 paymentId);
    event PaymentDeactivated(uint256 indexed paymentId, address indexed owner);
    event TokenSupplied(address indexed sender, address indexed tokenAddress, uint256 amount);

    uint256 public paymentId;
    address private immutable chainlinkRefContract;
    address private immutable weth;

    mapping(uint256 => DataTypes.RecurringPayment) public scheduledPayments;
    mapping(address => mapping(address => uint256)) public tokenBalanceOf;

    mapping(address => uint256) public balanceOf;

    constructor() 
    // address _chainlinkRefContract,
    // address _weth,
    {
        // chainlinkRefContract = _chainlinkRefContract;
        chainlinkRefContract = address(1);
        // _weth = _weth;
        weth = address(2);
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

    function supply(uint256 amount) public {
        // check that user has enough funds
        require(IERC20(weth).balanceOf(msg.sender) >= amount, "Insufficient balance");
        // give scheduler approval to get funds from user
        require(IERC20(weth).approve(address(this), amount));
        // get funds from users
        require(IERC20(weth).transferFrom(msg.sender, address(this), amount));

        tokenBalanceOf[msg.sender][weth] += amount;

        emit TokenSupplied(msg.sender, weth, amount);
    }
}
