// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/*
 * In this example, the AuditableContract smart contract has a struct named AuditTrail to store relevant data such as the user address, 
 * action performed, and the timestamp of the action. The auditTrails array is used to store the audit trail logs.
 *
 * The addAuditTrail function allows users to add an audit trail entry by providing the action as a parameter. 
 * It creates a new AuditTrail object with the sender's address, the provided action, and the current timestamp. 
 * The new entry is then added to the auditTrails array, and the AuditTrailAdded event is emitted to signal the addition of a new audit trail.
 *
 * To use this contract, deploy it to an Ethereum network, and then call the addAuditTrail function whenever you want to add an audit trail entry. 
 * The action performed can be passed as an argument to the function.
 &
 * Each time the addAuditTrail function is called, a new entry will be added to the auditTrails array, 
 * and the AuditTrailAdded event will be emitted. You can listen to this event to capture and store the audit trail logs externally.
*/
// Reengineering the Audit with Blockchain and Smart Contracts - https://publications.aaahq.org/jeta/article-abstract/16/1/21/9276/Reengineering-the-Audit-with-Blockchain-and-Smart?redirectedFrom=fulltext

import "./IConsolidatedAuditTrail.sol";

contract ConsolidatedAuditTrail is IConsolidatedAuditTrail {
    // Array to store audit trail logs
    AuditTrail[] public auditTrails;

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    // Function to add an audit trail entry
    function addAuditTrail(address _owner, string calldata symbol,Transaction memory transaction, uint256 timestamp) external {
        require(_owner == owner,"not authorized");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, transaction.receiver, transaction.tokens, symbol, timestamp));
        AuditTrail memory trail = AuditTrail(msg.sender, hash, symbol, timestamp, transaction);
        auditTrails.push(trail);
        emit AuditTrailAdded(msg.sender, hash, symbol, timestamp, transaction);
    }

    function getAuditTrailBySymbol(string memory _symbol) external view returns (AuditTrail[] memory) {
        AuditTrail[] memory audit;
        uint256 index = 0;
        for (uint256 i=0; i < auditTrails.length; i++) {
            if (compareStrings(auditTrails[i].symbol,_symbol)) {
                AuditTrail memory _audit = AuditTrail(auditTrails[i].senderIMID,auditTrails[i].routedOrderID,auditTrails[i].symbol,auditTrails[i].eventTimestamp,auditTrails[i].session);
                audit[index++] = _audit;
            }
        }
        return audit;
    }

    // internal functions
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
