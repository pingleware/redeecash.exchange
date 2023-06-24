"use strict"

const express = require('express');
const {
    init,
    updateTokenContractAddress,
    registerUser,
    firmRegistration,
    brokerDealerRegistration,
    addUserToToken,
    registerTransferAgent,
    addTransferAgentToToken,
    getTransferAgents,
    performKYCVerification,
    applyForTokenListing,
    createTokenListing,
    getTokens,
    placeOrder,
    depositTokens,
    withdrawTokens,
    processFIXMessage,
    performSecurityChecks,
    runTests,
    handleCustomerSupportTicket,
    getTokenQuote,
    getOrderBook,
    getFirms
} = require("./api");


const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/**
 * Registration - Owner and Transfer Ageent Access
 */
app.post('/register/user', (req, res) => {
  const { name, email, password, wallet, access} = req.body;
  const status = registerUser(name, email, password, wallet, access);
  console.error(status);
  res.json(status);
})
app.post('/register/firm', (req, res) => {
  const { firmDetails } = req.body;
  const result = firmRegistration(firmDetails);
  res.json(result);
})
app.post('/register/brokerDealer', (req, res) => {
  const { brokerDealerDetails } = req.body;
  const result = brokerDealerRegistration(brokerDealerDetails);
  res.json(result);
})
app.post('/register/transferAgent', (req, res) => {
  const {pool,token,name,email,password,wallet} = req.body;
  const status = registerTransferAgent(pool,token,name,email,password,wallet);
  console.log(status);
  res.json(status);
})

app.get('/transferagents', async (req, res) => {
  const transferAgents = getTransferAgents();
  res.json(transferAgents);
})

app.get('/firms', async (req, res) => {
  const firms = await getFirms();
  res.json(firms);
})
/**
 * Token
 */
app.post('/token/user', (req, res) => {
  const { token, user } = req.body;
  const status = addUserToToken(token,user);
  console.log(status);
  res.json(status);
})
app.post('/token/transferAgent', (req, res) => {
  const {symbol,wallet} = req.body;
  const status = addTransferAgentToToken(symbol,wallet);
  console.log(status);
  res.json(status);
})
app.post('/token/update/address', (req, res) => {
  const {symbol,token} = req.body;
  const status = updateTokenContractAddress(symbol,token);
  console.log(status);
  res.json(status);
})
/**
 * Banking
 */
app.post('/depositTokens', (req, res) => {
  const { userId, amount, token } = req.body;
  const status = depositTokens(userId, amount, token)
  res.json(status);
});
app.post('/withdrawTokens', (req, res) => {
  const { userId, amount, token } = req.body;
  const status = withdrawTokens(userId, amount, token)
  res.json(status);
});
/**
 * AML and KyC
 */
app.post('/performKYCVerification', (req, res) => {
  const { userId, kycData } = req.body;
  const status = performKYCVerification(userId, kycData);
  res.json(status);
});
app.post('/performSecurityChecks', (req, res) => {
  const { userId, transaction } = req.body;
  const status = performSecurityChecks(userId, transaction)
  res.json(status);
});
/**
 * Order
 */
app.get('/orderbook', (req, res) => {
  const { symbol } = req.query;
  const _orderbook = getOrderBook(symbol);
  res.json({_orderbook});
})
app.get('/tokens',async (req, res) => {
    const tokens = await getTokens();
    console.log(tokens);
    res.json({status: true, tokens: tokens});  
})
app.post('/placeOrder', async function(req, res){
  const { userId, orderDetails } = req.body;
  const status = placeOrder(userId, JSON.parse(orderDetails));
  console.error(status);
  res.json(status);
});
/**
 * FIX Protocol
 */
app.post('/processFIXMessage', (req, res) => {
  const { message } = req.body;
  const status = processFIXMessage(message)
  res.json(status);
});
/**
 * Support
 */
app.post('/handleCustomerSupportTicket', (req, res) => {
  const { ticketDetails } = req.body;
  const status = handleCustomerSupportTicket(ticketDetails)
  res.json(status);
});
/**
 * Listing Services - Owner Access
 */
app.post('/symbol/new', (req, res) => {
  const {assetType,regulation,company} = req.body;

  const symbol = generateSymbol(assetType, regulation, company);
  res.json({symbol});
});
app.post('/applyForTokenListing', async (req, res) => {
  const { tokenDetails } = req.body;
  const status = await applyForTokenListing(tokenDetails);
  res.json(status);
});
app.post('/createTokenListing', (req, res) => {
  const {poolContract,offeringType,secFileNumber,name,symbol,tokens,price,owner,ownerPrivateKey} = req.body;
  const status = createTokenListing(poolContract,offeringType,secFileNumber,name,symbol,tokens,price,owner,ownerPrivateKey);
  console.log(status);
  res.json(status);
})


function fullNameToAbbreviation(fullName) {
  // Split the full name into individual words
  const words = fullName.split(' ');

  // Extract the first letter of each word
  const initials = words.map(word => word.charAt(0).toUpperCase());

  // Join the initials together to form the abbreviation
  const abbreviation = initials.join('');

  return abbreviation;
}
/**
 * Trading symbol has a 11 character limit, restricting the company abbrevition to six characters,
 * while the asset type is two characters and the regulation is three characters.
 * 
 * @param {*} assetType 
 * @param {*} regulation 
 * @param {*} companyName 
 * @returns 
 */
function generateSymbol(assetType, regulation, companyName="") {
  let symbol = '';

  const abbreviation = fullNameToAbbreviation(companyName).substr(0,5); // first six characters from the abbreviation

  // Add abbreviation
  if (abbreviation) {
    symbol += abbreviation.toUpperCase();
  } else {
    symbol += 'SAMPLE';
  }

  // Add prefix based on asset type
  switch (assetType) {
    case 'preferred':
      symbol += 'KV';
      break;
    case 'common':
      symbol += 'KX';
      break;
    case 'currency':
      symbol += 'RC';
      break;
    case 'commodity':
      symbol += 'CM';
      break;
    case 'debt':
      symbol += 'DT';
      break;
    case 'employee':
      symbol += 'EP';
      break;
    case 'merger':
    case 'aquisition':
      symbol += 'MA';
      break;
    case 'treasury':
      symbol += 'TR';
      break;
    // Add more cases for other asset types if needed
    default:
      symbol += 'NO';
  }

  // Add suffix based on regulation
  switch (regulation) {
    case '506b':
      symbol += '-5B';
      break;
    case '506c':
      symbol += '-5C';
      break;
    case 'AT1':
      symbol += '-A1';
      break;
    case 'AT2':
      symbol += '-A2';
      break;
    case 'S1':
      symbol += '-S1';
      break;
    case 'S3':
      symbol += '-S3';
      break;
    case 'F1':
      symbol += '-F1';
      break;
    case 'F3':
      symbol += '-F3';
      break;
    // Add more cases for other regulation types if needed
    default:
      symbol += '-00';
  }

  return symbol;
}

/**
 * Quoting
 */
app.get('/getTokenQuote', (req, res) => {
  const { tokenSymbol } = req.body;
  const status = getTokenQuote(tokenSymbol)
  res.json(status);
});

app.get('/quote/update', async (req, res) =>  {
  const fetchUrl = require("fetch").fetchUrl;
  const {
    handleProvideDataRequest,
    getRequestId,
    getData,
    requestData,
  } = require('./oracleRequest');
    
  fetchUrl('https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/xau/usd.json', async function(error, meta, body){
    const quote = JSON.parse(body.toString());
    const xauusd = quote.usd;
    console.log(xauusd);

    await requestData("https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/xau/usd.json", async function(result){
      let requestId = result;
      console.log(requestId);
    
      const transaction = await handleProvideDataRequest(requestId,xauusd);
      res.json(transaction);
    });
  });
})

app.post('/quote/update', async (req,res) => {
  const { endpoint } = req.body;
  const { requestData } = require('./oracleRequest');
  await requestData(endpoint, function(transaction){
    res.json(transaction);
  });
})

app.post('/mail', async (req, res) => {
  const send = require('./mailer');

  const results = await send({from: req.from, fromName: req.fromName},{to: req.to, toName: req.toName},req.subject,req.message);
  res.json(results);
})

/**
 * Starting Server
 */
const port = 3000; 

app.listen(port, () => {
  init();
  console.log(`Server is listening on port ${port}`);
});

