// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import {Scheduler} from "contracts/core/Scheduler.sol";
import {WETH} from "contracts/core/Token.sol";
import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract SchedulerTest is Test {
    Scheduler internal scheduler;
    WETH internal weth;

    function setUp() public {
        // create contract and provide it with 1 eth
        weth = new WETH();
        scheduler = new Scheduler({_weth: address(weth)});
    }

    /// @notice Assert that a supplier can supply assets weth
    function testSupply(uint256 amount) public {
        address supplier = address(100);
        weth.mint(supplier, 2 ether);

        uint256 supplyAmount = 1 ether;
        vm.startPrank(supplier);
        weth.increaseAllowance(address(scheduler), 5 ether);
        scheduler.supply(supplyAmount);

        uint256 newBalance = scheduler.balanceOf({user: supplier, erc20: address(weth)});
        emit log_named_uint("Supplied balance of user after supply", newBalance);
        assertEq(newBalance, supplyAmount);
    }

    function testSchedulePayment(address to, uint256 amount, uint8 dayOfMonth) public {
        vm.assume(to != address(0));
        vm.assume(dayOfMonth < 30);

        uint256 paymentId = scheduler.schedulePayment(to, amount, dayOfMonth);

        DataTypes.RecurringPayment memory payment = scheduler.getPaymentById(paymentId);
        assertEq(payment.active, true);

        emit log_named_uint("paymentId", payment.paymentId);
    }

    function testExecutePayment() public {}
}
