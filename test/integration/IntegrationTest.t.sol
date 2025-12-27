// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";

contract InteractionsTest is Test {

    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address alice = makeAddr("alice");


    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // пополняем баланс алисы на 10 eth
        vm.deal(alice, STARTING_USER_BALANCE);
    }


    function testUserCanFundAndOwnerWithdraw() public {
        // алиса баланс до
        uint256 preUserBalance = alice.balance;

        // баланс владельца до
        uint256 preOwnerBalance = fundMe.getOwner().balance;

        // следующая транзакция от алисы
        vm.prank(alice);

        // alice отправляет 0.1 ETH в контракт.
        fundMe.fund{value: SEND_VALUE}();

        // баланс контракта 0.1 eth
        uint256 contractBalance = address(fundMe).balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        // весь баланс переводится владельцу котракта
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // баланс алисы после 9.9
        uint256 afterUserBalance = alice.balance;

        // баланс владельца после 0.1
        uint256 afterOwnerBalance = fundMe.getOwner().balance;

        // контракт пуст
        assertEq(address(fundMe).balance, 0);

        // afterUserBalance 9.9 + SEND_VALUE 0.1 == preUserBalance 10
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);

        // 0.1 - 0 == 0.1
        assertEq(
            afterOwnerBalance - preOwnerBalance,
            contractBalance
        );
    }


}