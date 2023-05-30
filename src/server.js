"use strict"

const express = require('express');
const {
    registerUser,
    performKYCVerification,
    applyForTokenListing,
    placeOrder,
    depositTokens,
    withdrawTokens,
    processFIXMessage,
    performSecurityChecks,
    runTests,
    handleCustomerSupportTicket,
    getTokenQuote,
    getOrderBook
} = require("./api");

const app = express();

app.post('/register', (req, res) => {
  const { email, password } = req.body;
  const status = registerUser(email, password);
  res.json(status);
})

app.post('/performKYCVerification', (req, res) => {
  const { userId, kycData } = req.body;
  const status = performKYCVerification(userId, kycData);
  res.json(status);
});
app.post('/applyForTokenListing', (req, res) => {
  const { tokenDetails } = req.body;
  const status = applyForTokenListing(tokenDetails);
  res.json(status);
});
app.post('/placeOrder', (req, res) => {
  const { userId, orderDetails } = req.body;
  const status = placeOrder(userId, orderDetails)
  res.json(status);
});
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
app.post('/processFIXMessage', (req, res) => {
  const { message } = req.body;
  const status = processFIXMessage(message)
  res.json(status);
});
app.post('/performSecurityChecks', (req, res) => {
  const { userId, transaction } = req.body;
  const status = performSecurityChecks(userId, transaction)
  res.json(status);
});
app.get('/runTests', (req, res) => {
  const status = runTests()
  res.json(status);
});
app.post('/handleCustomerSupportTicket', (req, res) => {
  const { ticketDetails } = req.body;
  const status = handleCustomerSupportTicket(ticketDetails)
  res.json(status);
});
app.get('/getTokenQuote', (req, res) => {
  const { tokenSymbol } = req.body;
  const status = getTokenQuote(tokenSymbol)
  res.json(status);
});
app.get('/orderbook', (req, res) => {
  const { symbol } = req.query;
  const _orderbook = getOrderBook(symbol);
  res.json({_orderbook});
})
app.post('/symbol/new', (req, res) => {
  const {assetType,regulation,company} = req.body;

  const symbol = generateSymbol(assetType, regulation, company);
  res.json({symbol});
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

function generateSymbol(assetType, regulation, companyName) {
  let symbol = '';

  const abbreviation = fullNameToAbbreviation(companyName);

  // Add abbreviation
  if (abbreviation) {
    symbol += abbreviation.toUpperCase();
  } else {
    symbol += 'UNK';
  }

  // Add prefix based on asset type
  switch (assetType) {
    case 'stock':
      symbol += 'STK';
      break;
    case 'currency':
      symbol += 'CUR';
      break;
    case 'commodity':
      symbol += 'COM';
      break;
    case 'debt':
      symbol += 'DBT';
      break;
    // Add more cases for other asset types if needed
    default:
      symbol += 'UNK';
  }

  // Add suffix based on regulation
  switch (regulation) {
    case '506b':
      symbol += '-506B';
      break;
    case '506c':
      symbol += '-506C';
      break;
    case 'AT1':
      symbol += '-AT1';
      break;
    // Add more cases for other regulation types if needed
    default:
      symbol += '-UNK';
  }

  return symbol;
}



const port = 3000;

app.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});

