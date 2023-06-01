// Import web3.js library and create a web3 instance
const Web3 = require('web3');
const web3 = new Web3('http://127.0.0.1:8545');

// Set the contract address and ABI
const oracleContractAddress = '0x65FC2458D5867C9Fe31d5bEddBa6fb72cC564B4F';
const oracleContractABI = [
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "data",
                    "type": "string"
                }
            ],
            "name": "DataProvided",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "uint256",
                    "name": "id",
                    "type": "uint256"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "requester",
                    "type": "address"
                },
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "apiEndpoint",
                    "type": "string"
                }
            ],
            "name": "DataRequested",
            "type": "event"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_requestId",
                    "type": "uint256"
                },
                {
                    "internalType": "string",
                    "name": "_data",
                    "type": "string"
                }
            ],
            "name": "provideData",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_apiEndpoint",
                    "type": "string"
                }
            ],
            "name": "requestData",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_requestId",
                    "type": "uint256"
                }
            ],
            "name": "getData",
            "outputs": [
                {
                    "internalType": "string",
                    "name": "",
                    "type": "string"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        }
    ];

// Create a contract instance
const oracleContract = new web3.eth.Contract(oracleContractABI, oracleContractAddress);

// Maintain a list of provideData requests
const provideDataRequests = {};


// Function to provide data to the Oracle contract
async function provideData(requestId, priceData) {
  try {
    const accounts = await web3.eth.getAccounts();
    const requester = accounts[0]; // Use the first account as the requester

    // Call the provideData function of the Oracle contract
    const transaction = await oracleContract.methods.provideData(requestId, priceData).send({ from: requester });

    console.log('Price data provided successfully for request ID:', requestId);

    // Remove the request from the list once it is completed
    delete provideDataRequests[requestId];
    return transaction;
  } catch (error) {
    console.error('Error providing price data:', error);
  }
}

// Function to handle new provideData requests
function handleProvideDataRequest(requestId, priceData) {
  // Store the request in the list
  provideDataRequests[requestId] = priceData;
  console.log([requestId,priceData]);

  // Call the provideData function to send the data to the Oracle contract
  return provideData(requestId, priceData);
}

module.exports = handleProvideDataRequest;
// Example usage
//const requestId = '<request_id>';
//const priceData = '<price_data>';

// Handle the provideData request and store it in the list
//handleProvideDataRequest(requestId, priceData);
