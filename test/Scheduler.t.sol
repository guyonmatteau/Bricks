// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Scheduler} from "contracts/Scheduler.sol";

contract SChedulerTest is Test {
    Scheduler internal scheduler;

    function setUp() public {
        // create contract and provide it with 1 eth

        scheduler = new Scheduler();
    }

    function testSchedulePayment(address to, uint256 amount, uint8 dayOfMonth) public {
        vm.assume(to != address(0));
        vm.assume(dayOfMonth < 30);

        uint256 paymentId = scheduler.schedulePayment(to, amount, dayOfMonth);

        Scheduler.Payment memory payment = scheduler.getPaymentById(paymentId);
        assertEq(payment.active, true);

        emit log_named_uint("paymentId", payment.paymentId);
    }

    function testExecutePayment() public {}
}
