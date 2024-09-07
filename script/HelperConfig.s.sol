// SPDX-License-Identifier: SEE LICENSE IN LICENSE

//1.Deploy mocks when we are on a local anvil chain
//2.keep track of contract address across different chains
//Sepolia ETH/USD
//Mainnet ETH/USD
pragma solidity ^0.8.18;
//next import allows access to the vm  
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script {
    //If we are on a local anvil, we deploy mocks
    //Otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkconfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_UNIT_PRICE=2000e8;
    uint256 public constant SEPOLIA_CHAINID = 11155111;
    constructor() {
        if (block.chainid == SEPOLIA_CHAINID) {
            activeNetworkconfig = getSepliaEthConfig();
        } else {
            activeNetworkconfig = creat_AnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address pricefeed;
    }

    function getSepliaEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaNetwork = NetworkConfig({pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaNetwork;
    }

    function creat_AnvilEthConfig() public returns (NetworkConfig memory){
        if (activeNetworkconfig.pricefeed != address(0)) {
            return activeNetworkconfig;
        }
        //Deploy the mocks
        //return the mockaddress
        vm.startBroadcast();

        MockV3Aggregator mockpricefeed = new MockV3Aggregator(DECIMALS, INITIAL_UNIT_PRICE);

        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({pricefeed: address(mockpricefeed)});

        return anvilConfig;
    }
}