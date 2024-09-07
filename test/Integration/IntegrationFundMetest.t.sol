// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe_Funds, FundeMe_Withdrawal} from  "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.S.sol";
import {FundMe} from "../../src/FundMe.sol";
contract Integrated_FundMeTest is Test {
    FundMe fundMe;
    //fake user to send tx
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundMe = deployfundme.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testUserInteractions() public {
        FundMe_Funds fundeFundMe = new FundMe_Funds();
        fundeFundMe.fundeFundMe(address(fundMe));

        FundeMe_Withdrawal withdraw_funds = new FundeMe_Withdrawal();
        withdraw_funds.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }

}