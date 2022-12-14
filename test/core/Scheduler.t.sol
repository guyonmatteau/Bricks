// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Scheduler} from "contracts/core/Scheduler.sol";
import {DataTypes} from "contracts/libraries/DataTypes.sol";

contract SchedulerTest is Test {
    Scheduler internal scheduler;

    ERC20 internal weth;
    ERC20 internal usdc;
    address user = address(100);
    address to = address(300);

    /// addresss to test against Main or Goerli fork
    //address internal constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // mainnet
    //address internal constant _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // mainnet
    address internal constant _uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // both main and goerli
    
    address internal constant _weth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; // goerli
    address internal constant _usdc = 0x2f3A40A3db8a7e3D09B0adfEfbCe4f6F81927557; // goerli
    address internal constant _feedETHUSD = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e; // goerli

    function setUp() public {
        // create contract and provide it with 1 eth
        weth = ERC20(_weth);
        usdc = ERC20(_usdc);
        scheduler = new Scheduler({
            _weth: _weth,
            _usdc: _usdc,
            _uniswapRouter: _uniswapRouter,
            _feedETHUSD: _feedETHUSD
        });
    }

    /// @dev This is utility test to check if we can mint WETH on mainnet fork
    function testMintWETH() public {
        vm.deal(user, 4 ether);
        assertEq(address(user).balance, 4 ether);

        vm.startPrank(user);

        // check that minting of weth is succesfull
        (bool success,) = address(weth).call{value: 2 ether}("");
        assertTrue(success, "WETH mint not succesfull");

        uint256 wethBalanceOfUser = weth.balanceOf(user);
        assertEq(wethBalanceOfUser, 2 ether);
        vm.stopPrank();
    }

    /// @notice Assert that a supplier can supply assets weth
    function testSupplyWETH() public {
        // first mint some WETH
        testMintWETH();

        vm.startPrank(user);
        uint256 supplyAmount = 0.3 ether;
        bool approval = weth.approve({spender: address(scheduler), amount: 0.5 ether});
        assertTrue(approval, "WETH approval failed");
        scheduler.supply(supplyAmount);

        uint256 suppliedAmount = scheduler.balanceOf({user: user, erc20: address(weth)});

        assertEq(suppliedAmount, supplyAmount, "Supply to protocol not succesfull");
        vm.stopPrank();
    }

    /// @notice assert that payment is added
    function testSchedulePayment() public returns (uint256) {
        vm.startPrank(user);
        uint256 paymentId = scheduler.schedulePayment({to: to, amount: 0.2 ether, dayOfMonth: 2});

        DataTypes.RecurringPayment memory payment = scheduler.getPaymentById(paymentId);

        emit log_named_uint("paymentId", payment.paymentId);
        return paymentId;
    }

    /// @notice assert that protocol can manually execute ERC20 transfer
    function testExecutePayment() public {
        // supply eth to contract (this is calling two other tests, not really best practice but fine for now)
        testSupplyWETH();

        // schedule payment and get payment ID
        uint256 paymentId = testSchedulePayment();

        uint256 wethBalanceOfTo = weth.balanceOf(to);
        assertEq(wethBalanceOfTo, 0, "WETH balance of recipient pre-transfer not 0");

        // execute payment
        scheduler.executePayment(paymentId);
        uint256 newBalanceOfTo = weth.balanceOf(to);
        assertEq(newBalanceOfTo, 0.2 ether, "Recipient WETH balance post-transfer not as expected");

        // post payment check
        uint256 newBalanceOfUser = scheduler.balanceOf(user, address(weth));
        assertEq(newBalanceOfUser, 0.1 ether, "New supply of user in protocl not as expected");
    }

    /// //@notice assert that protcol can swap funds for user
    //function testSwap() public {

    ///// supply to contract
    //testSupplyWETH();
    //assertEq(scheduler.balanceOf(user, address(usdc)), 0, "USDC balance user pre-swap is not 0");

    //vm.startPrank(user);

    //scheduler.swap({amount: 1000000000000 wei, owner: user});

    //uint256 usdcSupplyOfUser = scheduler.balanceOf({user: user, erc20: address(usdc)});

    //emit log_named_uint("usdcSupplyOfUserPostSwap", usdcSupplyOfUser);

    //}

    function testGetLatestPrice() public {
        (uint256 decimals, int256 latestPrice) = scheduler.getLatestPrice();
        emit log_named_uint("Number of decimals in latest round", decimals);
        emit log_named_int("Latest ETH/USD on block x Goerli", latestPrice);
    }
}
