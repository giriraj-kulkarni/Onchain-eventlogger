// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin/contracts/access/Ownable.sol";
import "../src/Wallnut.sol";  // Import Wallnut contract

contract EventLogger is Ownable {
    Wallnut public wallnutToken; // Declare wallnutToken as a Wallnut type

    // Constructor to initialize the contract with Wallnut token and an initial owner
    constructor(address _wallnutToken, address initialOwner) Ownable(initialOwner) {
        wallnutToken = Wallnut(_wallnutToken); // Initialize the Wallnut token
    }

    // Function to set Wallnut token address (onlyOwner)
    function setWallnutToken(address _wallnutToken) external onlyOwner {
        wallnutToken = Wallnut(_wallnutToken);  // Set the wallnutToken to the new address
    }

    // Modifier to check if the user has at least 5 Wallnut tokens
    modifier hasMinWallnutBalance() {
        require(wallnutToken.balanceOf(msg.sender) >= 5 * 10 ** 18, "You need at least 5 Wallnut tokens to interact with this contract");
        _;
    }

    // Struct to store the logs along with expiry information
    struct LogData {
        string logs;  // The actual logs (could be a JSON string or raw data)
        uint256 timestamp;  // Timestamp of when the logs were stored
        uint256 expiryTime; // Expiry time of the logs
        bool isValid;  // Indicates whether the logs are still valid
    }

    // Mapping to store logs for each user
    mapping(address => LogData) public userLogs;

    // Constants
    uint256 public constant SEVEN_DAY_COST = 1 * 10 ** 18;  // Cost for 7 days (1 Wallnut)
    uint256 public constant MONTH_COST = 3 * 10 ** 18;  // Cost for 30 days (3 Wallnut)
    uint256 public constant PDF_ACCESS_COST = 0.5 * 10 ** 18;  // Cost to access logs in PDF format (0.5 Wallnut)

    // Events
    event LogsStored(address indexed user, string logs, uint256 duration);
    event LogsAccessed(address indexed user, string logs);

    // Modifier to check if the user has enough Wallnut tokens to interact
    modifier hasWallnut(uint256 amount) {
        require(wallnutToken.balanceOf(msg.sender) >= amount, "Insufficient Wallnut balance");
        _;
    }

    // Function to allow users to store their logs for either 7 days or 30 days
    function storeLogs(string memory logs, uint256 duration) external hasWallnut(duration == 7 ? SEVEN_DAY_COST : MONTH_COST) hasMinWallnutBalance {
        // Check if the duration is valid (7 days or 30 days)
        require(duration == 7 || duration == 30, "Invalid duration");

        // Transfer Wallnut tokens for storage
        uint256 cost = duration == 7 ? SEVEN_DAY_COST : MONTH_COST;
        wallnutToken.transferFrom(msg.sender, address(this), cost);

        // Calculate the expiry time based on the duration
        uint256 expiryTime = block.timestamp + (duration * 1 days);

        // Store the logs for the user
        userLogs[msg.sender] = LogData({
            logs: logs,
            timestamp: block.timestamp,
            expiryTime: expiryTime,
            isValid: true
        });

        emit LogsStored(msg.sender, logs, duration);
    }

    // Function to check if the user's logs are still valid (within the expiry period)
    function isLogsValid(address user) public view returns (bool) {
        LogData memory data = userLogs[user];
        return (data.isValid && data.expiryTime >= block.timestamp);
    }

    // Function to access the logs (view logs in PDF format)
    function accessLogsAsPDF() external hasWallnut(PDF_ACCESS_COST) hasMinWallnutBalance {
        // Ensure the logs are valid and have not expired
        require(isLogsValid(msg.sender), "Logs have expired or do not exist");

        // Transfer Wallnut tokens for PDF access
        wallnutToken.transferFrom(msg.sender, address(this), PDF_ACCESS_COST);

        // Emit an event when the logs are accessed
        emit LogsAccessed(msg.sender, userLogs[msg.sender].logs);
    }

    // Function to check the user's logs (public view function)
    function getUserLogs(address user) external view returns (string memory) {
        require(isLogsValid(user), "Logs have expired or do not exist");
        return userLogs[user].logs;
    }

    // Admin function to withdraw Wallnut tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        wallnutToken.transfer(msg.sender, amount);
    }
}
