// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/EventLogger.sol";  // Adjust the path based on your project structure
import "../src/Wallnut.sol";  // Adjust the path based on your project structure

contract DeployScript is Script {
    address public admin = 0x56E4cD145088717Ac52563d80dfaeC44b224C1ce; // Replace with the actual admin address

    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy Wallnut token (ERC20) with `admin` as the initial owner
        Wallnut wallnutToken = new Wallnut(admin);

        // Deploy EventLogger contract with Wallnut token address and `admin` as the initial owner
        EventLogger eventLogger = new EventLogger(address(wallnutToken), admin);

        // Log contract addresses
        console.log("Wallnut token deployed at:", address(wallnutToken));
        console.log("EventLogger contract deployed at:", address(eventLogger));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
