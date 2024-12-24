// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Test.sol";
import "../src/Wallnut.sol";
import "../src/EventLogger.sol";

contract EventLoggerTest is Test {
    Wallnut public wallnutToken;
    EventLogger public eventLogger;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this); // Set the contract deployer as the owner
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy Wallnut token with the owner
        wallnutToken = new Wallnut(owner);

        // Deploy EventLogger with the Wallnut token address and the owner
        eventLogger = new EventLogger(address(wallnutToken), owner);

        // Mint initial tokens for test users
        wallnutToken.mint(user1, 100 * 10 ** 18); // Mint 100 tokens to user1
        wallnutToken.mint(user2, 100 * 10 ** 18); // Mint 100 tokens to user2
    }

    // Test initial token supply and owner balance
    function testInitialSupply() public {
        uint256 initialSupply = wallnutToken.totalSupply();
        assertEq(initialSupply, 1000 * 10 ** 18); // 1000 tokens minted to owner
        assertEq(wallnutToken.balanceOf(owner), 1000 * 10 ** 18); // Owner balance check
    }

    // Test minting functionality by the owner
    function testMintTokens() public {
        wallnutToken.mint(user1, 50 * 10 ** 18);
        assertEq(wallnutToken.balanceOf(user1), 150 * 10 ** 18); // 100 + 50 tokens
    }

    // Test storing logs by user1 with sufficient balance
    function testStoreLogsWithValidBalance() public {
        vm.startPrank(user1);

        // Approve EventLogger to spend user1's tokens for log storage
        wallnutToken.approve(address(eventLogger), 5 * 10 ** 18);
        uint256 initialBalance = wallnutToken.balanceOf(user1);

        // Store logs for 7 days (costs 1 token)
        eventLogger.storeLogs("User1's log for 7 days", 7);
        assertEq(wallnutToken.balanceOf(user1), initialBalance - eventLogger.SEVEN_DAY_COST());

        vm.stopPrank();
    }

    // Test attempting to store logs with insufficient balance
    function testStoreLogsInsufficientBalance() public {
        vm.startPrank(user2);

        // Burn tokens to simulate insufficient balance
        wallnutToken.burn(user2, 98 * 10 ** 18);

        // Attempt to store logs and expect revert due to low balance
        vm.expectRevert("Insufficient Wallnut balance");
        eventLogger.storeLogs("User2's log for 7 days", 7);

        vm.stopPrank();
    }

    // Test accessing logs in PDF format for user1
    function testAccessLogsAsPDF() public {
        vm.startPrank(user1);

        // Approve EventLogger to spend user1's tokens
        wallnutToken.approve(address(eventLogger), 5 * 10 ** 18);

        // Store logs and check access
        eventLogger.storeLogs("User1's log for 7 days", 7);
        uint256 initialBalance = wallnutToken.balanceOf(user1);

        // Access logs as PDF (costs 0.5 token)
        eventLogger.accessLogsAsPDF();
        assertEq(wallnutToken.balanceOf(user1), initialBalance - eventLogger.PDF_ACCESS_COST());

        vm.stopPrank();
    }

    // Test isLogsValid function
    function testIsLogsValid() public {
        vm.startPrank(user1);

        // Approve EventLogger to spend user1's tokens
        wallnutToken.approve(address(eventLogger), 5 * 10 ** 18);

        // Store logs for 7 days
        eventLogger.storeLogs("User1's log for 7 days", 7);

        // Check if logs are valid immediately after storing
        assertTrue(eventLogger.isLogsValid(user1));

        vm.stopPrank();
    }

    // Test withdrawTokens by the owner
    function testWithdrawTokens() public {
        vm.startPrank(owner);

        // Mint tokens to EventLogger and then withdraw
        wallnutToken.mint(address(eventLogger), 10 * 10 ** 18);
        uint256 contractBalance = wallnutToken.balanceOf(address(eventLogger));

        // Owner withdraws tokens from EventLogger
        eventLogger.withdrawTokens(contractBalance);
        assertEq(wallnutToken.balanceOf(owner), contractBalance + wallnutToken.balanceOf(owner));

        vm.stopPrank();
    }
}
