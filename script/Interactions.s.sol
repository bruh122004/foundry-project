// SPDX-License-Identifier: MIT
// Fund
// WithDraw
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundMe_Funds is Script{
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.01 ether;
    function fundeFundMe(address mostRecentlyDeployed) public {
        vm.prank(USER);
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log(mostRecentlyDeployed, "Funded FundeMe with %s", SEND_VALUE);
    }
        
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundeFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}   

contract FundeMe_Withdrawal is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();

    }
        
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
        
    
}

