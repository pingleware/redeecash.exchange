// Import web3.js library and create a web3 instance
const Web3 = require('web3');
const web3 = new Web3('http://127.0.0.1:8545');

// Set the contract address and ABI
const oracleContractAddress = '0xd9E32eA5ea7841Bc0A906F7e2B5a93D0124f8549';
const oracleABI = request('./abi'); 

// Create a contract instance
const oracleContract = new web3.eth.Contract(JSON.parse(oracleABI), oracleContractAddress);

// Maintain a list of provideData requests
const provideDataRequests = {};


// Function to provide data to the Oracle contract
async function provideData(requestId, priceData) {
  try {
    const accounts = await web3.eth.getAccounts();
    const requester = accounts[0]; // Use the first account as the requester

    // Call the provideData function of the Oracle contract
    const transaction = await oracleContract.methods.provideData(requestId, priceData).send({ from: requester });

    console.log('Price data provided successfully for request ID:', requestId, ' with price data of ', priceData);

    // Remove the request from the list once it is completed
    delete provideDataRequests[requestId];
    return transaction;
  } catch (error) {
    console.error('Error providing price data:', error);
  }
}

async function getRequestId(callback) {
    try {
        const accounts = await web3.eth.getAccounts();
        const requester = accounts[0]; // Use the first account as the requester
    
        // Call the provideData function of the Oracle contract
        oracleContract.methods.getRequestId().call(
            { 
                from: requester 
            }
        ).then(function(requestId) {
            console.log(requestId)
            callback(requestId);
        });    
    } catch(error) {
        console.error('Error providing price data:', error);
    }
}

async function getData(requestId) {
    try {
        const accounts = await web3.eth.getAccounts();
        const requester = accounts[0]; // Use the first account as the requester
    
        // Call the provideData function of the Oracle contract
        const data = await oracleContract.methods.getData(requestId).call({ from: requester });
        return data;
    
    } catch(error) {
        console.error('Error providing price data:', error);
    }

}

async function requestData(endpoint,callback) {
    try {
        const accounts = await web3.eth.getAccounts();
        const requester = accounts[0]; // Use the first account as the requester
    
        // Call the provideData function of the Oracle contract
        await oracleContract.methods.requestData(endpoint).call({ from: requester })
        .then((result) => {
            callback(result);
        });
    
    } catch(error) {
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

module.exports = {
    handleProvideDataRequest,
    getRequestId,
    getData,
    requestData,
}
