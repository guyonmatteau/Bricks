// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/interfaces/IUniswapV2Router02.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract Scheduler {
    event PaymentScheduled(uint256 paymentId, address indexed owner, address indexed to, uint256 amount);
    event PaymentExecuted(uint256 indexed paymentId);
    event PaymentDeactivated(uint256 indexed paymentId, address indexed owner);
    event TokenSupplied(address indexed sender, address indexed tokenAddress, uint256 amount);
    event CheckingReserve(uint112 reserve0, uint112 reserve1, uint256 amount0, uint256 amount1);

    uint256 public paymentId;
    //address private immutable chainlinkRefContract;
    ERC20 private immutable weth;
    ERC20 private immutable usdc;
    IUniswapV2Router02 private immutable router;

    // chainlink
    AggregatorV3Interface internal priceFeed;

    // paymentId => payment
    mapping(uint256 => DataTypes.RecurringPayment) public scheduledPayments;
    // user => ERC20 => balance
    mapping(address => mapping(address => uint256)) public tokenBalanceOf;

    constructor(
        //address _chainlinkRefContract,
        address _weth,
        address _usdc,
        address _uniswapRouter,
        address _feedETHUSD
    ) {
        //chainlinkRefContract = _chainlinkRefContract;
        weth = ERC20(_weth);
        usdc = ERC20(_usdc);
        router = IUniswapV2Router02(_uniswapRouter);
        priceFeed = AggregatorV3Interface(_feedETHUSD);
    }

    receive() external payable {}

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
            isActive: true
        });
        scheduledPayments[paymentId] = newPayment;
        emit PaymentScheduled(paymentId, msg.sender, to, amount);
        return paymentId;
    }

    function getPaymentById(uint256 id) public view returns (DataTypes.RecurringPayment memory) {
        require(scheduledPayments[id].isActive, "Payment not found");
        return scheduledPayments[id];
    }

    function executePayment(uint256 id) public {
        DataTypes.RecurringPayment memory payment = getPaymentById(id);

        require(
            tokenBalanceOf[payment.owner][address(weth)] > payment.amount,
            "User does not have sufficient funds in protocol"
        );

        tokenBalanceOf[msg.sender][address(weth)] -= payment.amount;
        payment.lastExecuted = block.timestamp;
        scheduledPayments[id] = payment;
        bool success = IERC20(weth).transferFrom(address(this), payment.to, payment.amount);
        require(success, "Transaction Failed");

        emit PaymentExecuted(id);
    }

    function deactivatePayment(uint256 id) public {
        scheduledPayments[id].isActive = false;
        emit PaymentDeactivated(id, msg.sender);
    }

    /// @notice Swap ETH for required amount USDC
    /// @dev This should do XA
    /// @param amount Amount of USDC to swap to USDC
    function swap(uint256 amount, address owner) public {
        require(tokenBalanceOf[owner][address(weth)] >= amount, "Insufficient balance");

        // Pair WETH USDC
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(weth), address(usdc)));

        // get liquidity
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        uint256 amount0 = pair.token0() == address(weth) ? 0 : amount;
        uint256 amount1 = pair.token0() == address(weth) ? amount : 0;

        emit CheckingReserve(reserve0, reserve1, amount0, amount1);

        pair.swap({amount0Out: amount0, amount1Out: amount1, to: address(this), data: abi.encode("Data")});
    }

    /// @notice Request current WETH/USDC rate needed to determine how much ETH should be swapped
    /// @dev Requires chainlink for external data
    function getLatestPrice() public view returns (uint256 decimals, int256 price) {
        decimals = priceFeed.decimals();

        //(uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound)
        (, price,,,) = priceFeed.latestRoundData();
    }

    function supply(uint256 amount) public {
        // check that user has enough funds
        require(weth.balanceOf(msg.sender) >= amount, "Insufficient balance");
        // give scheduler approval to get funds from user
        require(weth.approve(address(this), amount));
        // get funds from users
        require(weth.transferFrom(msg.sender, address(this), amount));

        tokenBalanceOf[msg.sender][address(weth)] += amount;

        emit TokenSupplied(msg.sender, address(weth), amount);
    }

    function balanceOf(address user, address erc20) public view returns (uint256) {
        return tokenBalanceOf[user][erc20];
    }
}
