// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin/contracts/access/Ownable.sol";

contract Wallnut is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18; // Example max supply of 1 million tokens
    uint256 public totalMinted; // Track the total minted amount

    // Events for tracking minting and burning actions
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    // Constructor to initialize the Wallnut token with an initial owner
    constructor(address initialOwner) ERC20("Wallnut", "WALNUT") Ownable(initialOwner) {
        totalMinted = 0; // Initialize totalMinted to 0
        _mint(initialOwner, 1000 * 10 ** 18); // Mint 1000 tokens to the initial owner
        totalMinted += 1000 * 10 ** 18; // Update totalMinted
    }

    // Function to mint new Wallnut tokens, subject to max supply cap
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalMinted + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(to, amount);
        totalMinted += amount;

        emit TokensMinted(to, amount);
    }

    // Function to burn Wallnut tokens (can only be called by the owner)
    function burn(address from, uint256 amount) external onlyOwner {
        require(balanceOf(from) >= amount, "Insufficient balance to burn");
        _burn(from, amount);
        totalMinted -= amount;

        emit TokensBurned(from, amount);
    }

    // Optionally allow users to request minting of tokens with specific conditions
    function requestMint(uint256 amount) external onlyOwner {
        require(totalMinted + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(msg.sender, amount);  // Mint tokens directly to the user
        totalMinted += amount;

        emit TokensMinted(msg.sender, amount);
    }

    // Function to get the current supply of tokens minted so far
    function currentSupply() external view returns (uint256) {
        return totalMinted;
    }
}
