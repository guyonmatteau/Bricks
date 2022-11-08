// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Wallet} from "src/Wallet.sol";

contract WalletTest is Test {
    event Withdraw(address indexed from, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    Wallet internal newWallet;
    address internal owner = address(100);
    address internal nonOwner = address(200);
    uint256 withdrawAmount = 5e16;

    function setUp() public {
        // create contract and provide it with 1 eth
        vm.prank(owner);

        newWallet = new Wallet();
        vm.deal(address(newWallet), 1 ether);
    }

    function testSendEth() public {
        address(newWallet).call{value: 2 ether}("");
        uint256 balance = address(newWallet).balance;
        emit log_named_uint("balance", balance);
    }

    function testSucceedWithdraw() public {
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, true);
        emit Withdraw(address(newWallet), withdrawAmount);
        newWallet.withdraw(withdrawAmount);

        // check that address is increased.
        uint256 newBalance = address(owner).balance;
        assertEq(newBalance, withdrawAmount);
        vm.stopPrank();
    }

    function testWithdrawNoOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        newWallet.withdraw(withdrawAmount);
    }

    function testTransfer() public {
        address thirdParty = address(300);

        vm.expectEmit(true, true, false, true);
        emit Transfer(address(newWallet), thirdParty, withdrawAmount);

        vm.prank(owner);
        newWallet.transfer(thirdParty, withdrawAmount);
        assertEq(address(thirdParty).balance, withdrawAmount);
    }
}
