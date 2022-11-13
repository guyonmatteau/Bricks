// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import {Scheduler} from "contracts/core/Scheduler.sol";
import {WETH} from "contracts/core/Token.sol";
import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract SchedulerTest is Test {
    Scheduler internal scheduler;
    WETH internal weth;
    address supplier = address(100);

    function setUp() public {
        // create contract and provide it with 1 eth
        weth = new WETH();
        scheduler = new Scheduler({_weth: address(weth)});
        
        // provide supplier with ERC20
        weth.mint(supplier, 2 ether);
    }

    /// @notice Assert that a supplier can supply assets weth
    function testSupply(uint256 amount) public {
        uint256 supplyAmount = 1 ether;
        vm.startPrank(supplier);
        weth.increaseAllowance(address(scheduler), 5 ether);
        scheduler.supply(supplyAmount);

        uint256 newBalance = scheduler.balanceOf({user: supplier, erc20: address(weth)});
        emit log_named_uint("Supplied balance of user after supply", newBalance);
        assertEq(newBalance, supplyAmount);
    }

    /// @notice assert that payment is added
    function testSchedulePayment(address to, uint256 amount, uint8 dayOfMonth) public {
        vm.assume(to != address(0));
        vm.assume(dayOfMonth < 30);

        uint256 paymentId = scheduler.schedulePayment(to, amount, dayOfMonth);

        DataTypes.RecurringPayment memory payment = scheduler.getPaymentById(paymentId);

        emit log_named_uint("paymentId", payment.paymentId);
    }

    function testExecutePayment() public {
        uint256 supplyAmount = 1 ether;
        vm.startPrank(supplier);
        weth.increaseAllowance(address(scheduler), 5 ether);
        scheduler.supply(supplyAmount);

        // schedule and execute payment
        address to = address(300);
        uint256 paymentId = scheduler.schedulePayment(to, 0.5 ether, 2);

        scheduler.executePayment(paymentId);

        uint256 newBalanceOfTO = weth.balanceOf(to);
        uint256 newBalanceOfFrom = weth.balanceOf(supplier);
        assertEq(newBalanceOfTO, 0.5 ether);
        emit log_named_uint("Balance of supplier after transfer", newBalanceOfFrom);
        assert(newBalanceOfFrom < 1 ether);

    }
}
