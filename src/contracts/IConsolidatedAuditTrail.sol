// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface IConsolidatedAuditTrail {
    // Structure to store audit trail data
    struct Transaction {
        address sender;
        address receiver;
        uint256 tokens;
    }

    struct AuditTrail {
        address senderIMID;
        bytes32 routedOrderID;
        string symbol;
        uint256 eventTimestamp;
        Transaction session;
    }



    // Event emitted when an audit trail is added
    event AuditTrailAdded(address indexed user, bytes32 indexed routedOrderID, string symbol, uint256 timestamp, Transaction session);
   
    function addAuditTrail(string calldata symbol, Transaction memory transaction, uint256 timestamp) external;
    function getAuditTrailBySymbol(string memory symbol) external view returns (AuditTrail[] memory);
}