// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";

import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract Scheduler {
    event PaymentScheduled(
        uint256 paymentId,
        address indexed owner,
        address indexed to,
        uint256 amount
    );
    event PaymentExecuted(uint256 indexed paymentId);
    event PaymentDeactivated(uint256 indexed paymentId, address indexed owner);
    event TokenSupplied(
        address indexed sender,
        address indexed tokenAddress,
        uint256 amount
    );

    uint256 public paymentId;
    address private immutable chainlinkRefContract;
    address private immutable weth;
    address private immutable usdc;
    IUniswapV2Router02 private immutable router;

    // paymentId => payment
    mapping(uint256 => DataTypes.RecurringPayment) public scheduledPayments;
    // user => ERC20 => balance
    mapping(address => mapping(address => uint256)) public tokenBalanceOf;

    constructor(
        // address _chainlinkRefContract,
        address _weth,
        address _usdc,
        address _uniswapRouter
    ) {
        // chainlinkRefContract = _chainlinkRefContract;
        chainlinkRefContract = address(1);
        weth = _weth;
        usdc = _usdc;
        router = IUniswapV2Router02(_uniswapRouter);
    }

    receive() external payable {}

    /// @notice Schedule a recurring payment at any day of the month
    /// @dev The day of the month is not yet converted
    /// @return The id of the scheduled recurring payment
    function schedulePayment(
        address to,
        uint256 amount,
        uint8 dayOfMonth
    ) public returns (uint256) {
        require(dayOfMonth < 30, "dayOfMonth should be smaller than 30");
        paymentId++;
        DataTypes.RecurringPayment memory newPayment = DataTypes
            .RecurringPayment({
                paymentId: paymentId,
                owner: msg.sender,
                to: to,
                amount: amount,
                dayOfMonth: dayOfMonth,
                lastExecuted: 0,
                isActive: true
            });
        scheduledPayments[paymentId] = newPayment;
        emit PaymentScheduled(paymentId, msg.sender, to, amount);
        return paymentId;
    }

    function getPaymentById(
        uint256 id
    ) public view returns (DataTypes.RecurringPayment memory) {
        require(scheduledPayments[id].isActive, "Payment not found");
        return scheduledPayments[id];
    }

    function executePayment(uint256 id) public {
        DataTypes.RecurringPayment memory payment = getPaymentById(id);

        require(
            tokenBalanceOf[payment.owner][weth] > payment.amount,
            "User does not have sufficient funds in protocol"
        );

        tokenBalanceOf[msg.sender][weth] -= payment.amount;
        payment.lastExecuted = block.timestamp;
        scheduledPayments[id] = payment;
        bool success = IERC20(weth).transferFrom(
            address(this),
            payment.to,
            payment.amount
        );
        require(success, "Transaction Failed");

        emit PaymentExecuted(id);
    }

    function deactivatePayment(uint256 id) public {
        scheduledPayments[id].isActive = false;
        emit PaymentDeactivated(id, msg.sender);
    }

    /// @notice Swap ETH for required amount USDC
    /// @dev This should do XA
    /// @param amount Amount of ETH to swap for USDC
    function swap(uint256 amount, address owner) internal {
        
        require(tokenBalanceOf[owner][weth] >= amount,
                "Insufficient balance");
       
        // Pair WETH USDC
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(weth, usdc));
    

    }

    /// @notice Request current WETH/USDC rate needed to determine how much ETH should be swapped
    /// @dev Requires chainlink for external data
    function requestRate() internal {}

    function supply(uint256 amount) public {
        // check that user has enough funds
        require(
            IERC20(weth).balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );
        // give scheduler approval to get funds from user
        require(IERC20(weth).approve(address(this), amount));
        // get funds from users
        require(IERC20(weth).transferFrom(msg.sender, address(this), amount));

        tokenBalanceOf[msg.sender][weth] += amount;

        emit TokenSupplied(msg.sender, weth, amount);
    }

    function balanceOf(address user, address erc20) public returns (uint256) {
        return tokenBalanceOf[user][erc20];
    }
}
