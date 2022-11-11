// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

library DataTypes {
    // Recurring payment that can be submitted by the user
    struct RecurringPayment {
        uint256 paymentId;
        address owner;
        address to;
        uint256 amount;
        uint8 dayOfMonth;
        uint256 lastExecuted;
        bool active;
    }
}
