// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface IConsolidatedAuditTrail {

    // Struct representing an audit trail entry
    struct AuditEntry {
        address sender;     // Address of the sender
        bytes32 routedOrderID; 
        uint256 timestamp;  // Timestamp of the event
        string symbol;      // Symbol
        string eventType;   // Type of event being recorded
        string eventData;   // Additional data related to the event
    }

    
    // Event emitted when a new audit entry is added
    event AuditEntryAdded(string symbol, bytes32 indexed uti, address indexed sender, uint256 timestamp, string eventType, string eventData);
    
    function addAuditEntry(string memory symbol, string memory eventDetail, string memory eventType, string memory eventData) external;
    function getAuditTrail(string memory symbol, bytes32 uti) external view returns (AuditEntry[] memory);

    function setExchangeRate(uint256 newRate) external;
    function getExchangeRate() external view returns (uint256);
    function weiToUSD(uint256 weiAmount) external view returns (uint256);
    function usdToWei(uint256 usdAmount) external view returns (uint256);
    function usdToEth(uint256 usdAmount) external view returns (string memory);
}