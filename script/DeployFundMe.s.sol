// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script{

    function run() external returns(FundMe){
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetvorkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }  


// deploy in infura sepolia testnet
// forge script script/DeployFundMe.s.sol:DeployFundMe \
//   --rpc-url $RPC_URL \
//   --private-key $PRIVATE_KEY \
//   --broadcast







}