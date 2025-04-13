// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TipJar
 * @dev A contract for collecting tips with messages on the Monad blockchain
 */
contract TipJar {
    // Tip structure to store tip details
    struct Tip {
        address sender;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    // Array to store all tips
    Tip[] private tips;
    
    // Contract owner
    address public owner;
    
    // Events
    event TipReceived(
        address indexed sender,
        uint256 amount,
        string message,
        uint256 timestamp
    );
    
    event FundsWithdrawn(
        address indexed owner,
        uint256 amount,
        uint256 timestamp
    );
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    // Modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev Constructor sets the deployer as the initial owner
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Function to send a tip with a message
     * @param _message The message to include with the tip
     */
    function sendTip(string memory _message) external payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        
        // Create and store the new tip
        tips.push(Tip({
            sender: msg.sender,
            amount: msg.value,
            message: _message,
            timestamp: block.timestamp
        }));
        
        // Emit the TipReceived event
        emit TipReceived(msg.sender, msg.value, _message, block.timestamp);
    }
    
    /**
     * @dev Function to get the total number of tips
     * @return The count of tips received
     */
    function getTipCount() external view returns (uint256) {
        return tips.length;
    }
    
    /**
     * @dev Function to get details of a specific tip
     * @param _index The index of the tip to retrieve
     * @return Tip details (sender, amount, message, timestamp)
     */
    function getTip(uint256 _index) external view returns (
        address,
        uint256,
        string memory,
        uint256
    ) {
        require(_index < tips.length, "Tip index out of bounds");
        Tip memory tip = tips[_index];
        return (tip.sender, tip.amount, tip.message, tip.timestamp);
    }
    
    /**
     * @dev Function to get all tips (for frontend display)
     * @return An array of all tips
     */
    function getAllTips() external view returns (Tip[] memory) {
        return tips;
    }
    
    /**
     * @dev Function to withdraw all collected funds (owner only)
     */
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // Transfer the balance to the owner
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawal failed");
        
        // Emit the FundsWithdrawn event
        emit FundsWithdrawn(owner, balance, block.timestamp);
    }
    
    /**
     * @dev Function to transfer ownership (owner only)
     * @param _newOwner The address of the new owner
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner cannot be the zero address");
        
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
    
    /**
     * @dev Function to get the contract's current balance
     * @return The contract's MON balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Fallback function to receive plain MON transfers
    receive() external payable {
        // Store the tip with an empty message
        tips.push(Tip({
            sender: msg.sender,
            amount: msg.value,
            message: "",
            timestamp: block.timestamp
        }));
        
        emit TipReceived(msg.sender, msg.value, "", block.timestamp);
    }
}