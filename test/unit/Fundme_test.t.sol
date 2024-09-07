// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from  "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.S.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    //fake user to send tx
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user");
    address OTHER_USER = makeAddr("Other_user");

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundMe = deployfundme.run();
    }

    function test_Minmum_Dollar_is_5() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        
        
    }

    function test_owner_is_sender() public view {
        console.log(address(this));
        assertEq(fundMe.get_owner(), msg.sender);
    }
    
    function test_price_feed_accuracy() public view{
        assertEq(fundMe.getVersion(), 4);
    }

    
    function test_non_sufice_eth_amount() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function test_Fund_Updates_Funded_data_Structure() public funded{

        fundMe.fund{value: SEND_VALUE}();
        //test mappings values and keys
        assertEq(fundMe.getAdrresToamountFunded(USER), SEND_VALUE);
    }

    function test_adds_Funder_To_array_funders() public funded {

        fundMe.fund{value: SEND_VALUE}();
        
        assertEq(USER, fundMe.getFunder(0));
    }
    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        _;
    }

    function test_ownership_of_contract() public funded {
        vm.expectRevert();
        fundMe.withdraw();
        assertEq(fundMe.getAdrresToamountFunded(USER), 0);
    }

    function testWithDrawWithASingleFunder() public funded {
        //Arrange for the test
        uint256 starttingOwnerBalance = fundMe.get_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.get_owner());
        fundMe.withdraw();

        uint256 endingwnerBalance = fundMe.get_owner().balance;
        uint256 endingfundemebalance = address(fundMe).balance;
        assertEq(endingfundemebalance, 0);
        assertEq(starttingOwnerBalance + startingFundMeBalance, endingwnerBalance);

    }

    function test_withdraw_from_multiple_funders() public {
        //using uint160 because it's campatibal with and address, and easier for typer conversion
        //and optimal for storage
        uint160 numberofFunders = 10;
        uint160 startingIndex = 1;
        for(uint160 i = startingIndex; i < numberofFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

        }
        uint256 startingOwnerBalance = fundMe.get_owner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;
        //act
        vm.startPrank(fundMe.get_owner());
        fundMe.withdraw();
        vm.stopPrank();
        //assert
         
        assert(address(fundMe).balance == 0);
        assert(fundMe.get_owner().balance == startingFunderBalance + startingOwnerBalance);


        
    }
}
