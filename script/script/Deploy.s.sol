// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {StakingDapp} from "src/StakingDapp.sol";
import {Script, console} from "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        
        StakingDapp staking = new StakingDapp();
        
        console.log("StakingDapp deployed at:", address(staking));
        
        vm.stopBroadcast();
    }
}