// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Scheduler} from "contracts/core/Scheduler.sol";
import {DataTypes} from "contracts/libraries/DataTypes.sol";


contract SchedulerTest is Test {
    Scheduler internal scheduler;
    
    IERC20 internal weth;
    IERC20 internal usdc;
    address supplier = address(100);

    // mainnet addresses to test with
    address internal constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; 
    address internal constant _uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        
        // create contract and provide it with 1 eth
        weth = IERC20(_weth);
        usdc = IERC20(_usdc);
        scheduler = new Scheduler({
            _weth: _weth,
            _usdc: _usdc,
            _uniswapRouter: _uniswapRouter
        });

    }

    /// @notice Assert that a supplier can supply assets weth
    function testSupply(uint256 amount) public {
 
        // provide supplier with ERC20
        vm.deal(supplier, 3 ether);
        vm.startPrank(supplier);

        uint256 balanceOfSupplier = weth.balanceOf(supplier);
        emit log_named_uint("balanceOfSupplier pre mint", balanceOfSupplier);
        
        _weth.call{value: 1 ether}("");
        
        console.log("Break line");

        uint256 supplyAmount = 1 ether;
        vm.startPrank(supplier);
        //weth.increaseAllowance(address(scheduler), 5 ether);
        scheduler.supply(supplyAmount);

        uint256 newBalance = scheduler.balanceOf({
            user: supplier,
            erc20: address(weth)
        });
        emit log_named_uint(
            "Supplied balance of user after supply",
            newBalance
        );
        assertEq(newBalance, supplyAmount);
    }

    /// @notice assert that payment is added
    function testSchedulePayment(
        address to,
        uint256 amount,
        uint8 dayOfMonth
    ) public {
        vm.assume(to != address(0));
        vm.assume(dayOfMonth < 30);

        uint256 paymentId = scheduler.schedulePayment(to, amount, dayOfMonth);

        DataTypes.RecurringPayment memory payment = scheduler.getPaymentById(
            paymentId
        );

        emit log_named_uint("paymentId", payment.paymentId);
    }

    /// @notice assert that protocol can manually execute ERC20 transfer
    function testExecutePayment() public {
        // supply eth to contract
        address supplier2 = address(400);
        uint256 supplyAmount = 1 ether;
        vm.assume(supplier2 != address(0));
        //weth.mint(supplier22, 2 ether);

        vm.startPrank(supplier2);
        // allow before supplying (two step)
       // weth.increaseAllowance(address(scheduler), 5 ether);
        scheduler.supply(supplyAmount);

        uint256 suppliedBalance = scheduler.balanceOf(supplier2, address(weth));
        assertEq(suppliedBalance, supplyAmount);

        // schedule and execute payment
        address to = address(300);
        uint256 paymentId = scheduler.schedulePayment(to, 0.5 ether, 2);

        scheduler.executePayment(paymentId);

        uint256 newBalanceOfTo = weth.balanceOf(to);
        uint256 newBalanceOfFrom = weth.balanceOf(supplier2);
        assertEq(newBalanceOfTo, 0.5 ether);
        emit log_named_uint(
            "Balance of supplier2 after transfer",
            newBalanceOfFrom
        );

        assert(newBalanceOfFrom == 1 ether);
    }
}
