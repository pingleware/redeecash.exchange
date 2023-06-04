const catABI = `[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "receiver",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "tokens",
						"type": "uint256"
					}
				],
				"indexed": true,
				"internalType": "struct IConsolidatedAuditTrail.Transaction",
				"name": "routedOrderID",
				"type": "tuple"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "AuditTrailAdded",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_owner",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "receiver",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "tokens",
						"type": "uint256"
					}
				],
				"internalType": "struct IConsolidatedAuditTrail.Transaction",
				"name": "transaction",
				"type": "tuple"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "addAuditTrail",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "auditTrails",
		"outputs": [
			{
				"internalType": "address",
				"name": "senderIMID",
				"type": "address"
			},
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "receiver",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "tokens",
						"type": "uint256"
					}
				],
				"internalType": "struct IConsolidatedAuditTrail.Transaction",
				"name": "routedOrderID",
				"type": "tuple"
			},
			{
				"internalType": "string",
				"name": "symbol",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "eventTimestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_symbol",
				"type": "string"
			}
		],
		"name": "getAuditTrailBySymbol",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "senderIMID",
						"type": "address"
					},
					{
						"components": [
							{
								"internalType": "address",
								"name": "sender",
								"type": "address"
							},
							{
								"internalType": "address",
								"name": "receiver",
								"type": "address"
							},
							{
								"internalType": "uint256",
								"name": "tokens",
								"type": "uint256"
							}
						],
						"internalType": "struct IConsolidatedAuditTrail.Transaction",
						"name": "routedOrderID",
						"type": "tuple"
					},
					{
						"internalType": "string",
						"name": "symbol",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "eventTimestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct IConsolidatedAuditTrail.AuditTrail[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]`;

module.exports = catABI;