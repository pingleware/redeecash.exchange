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
    registerTransferAgentAndAssignToken,
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
app.post('/register/transferAgent', async (req, res) => {
  const {name,email,password,wallet} = req.body;
  const status = await registerTransferAgent(name,email,password,wallet);
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
  let name = ''; // RegA-Tier1-01JUL2023-Common

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
      name += '-Preferred'
      break;
    case 'common':
      symbol += 'KX';
      name += '-Common'
      break;
    case 'currency':
      symbol += 'RC';
      name += '-Currency'
      break;
    case 'commodity':
      symbol += 'CM';
      name += '-Commodity'
      break;
    case 'debt':
      symbol += 'DT';
      name += '-Debt'
      break;
    case 'employee':
      symbol += 'EP';
      name += '-Employee'
      break;
    case 'merger':
    case 'aquisition':
      symbol += 'MA';
      name += '-M&A'
      break;
    case 'treasury':
      symbol += 'TR';
      name += '-Treasury'
      break;
    // Add more cases for other asset types if needed
    default:
      symbol += 'NO';
  }

  // Add suffix based on regulation
  switch (regulation) {
    case '506b':
      symbol += '-5B';
      name = 'RegD-506B-' + name;
      break;
    case '506c':
      symbol += '-5C';
      name = 'RegD-506C-' + name;
      break;
    case 'AT1':
      symbol += '-A1';
      name = 'RegA-Tier1-' + name;
      break;
    case 'AT2':
      symbol += '-A2';
      name = 'RegA-Tier2-' + name;
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
 * Contracts
 */
// Returns a list of contracts.
app.get('/trading/contracts', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 107,
        "label": "BTC-Mini-25AUG2021-300000-Call",
        "name": null,
        "is_call": true,
        "active": true,
        "strike_price": 30000000,
        "min_increment": 1,
        "date_live": "2021-02-01 05:00:00+0000",
        "date_expires": "2021-02-19 21:00:00+0000",
        "date_exercise": "2021-02-19 22:00:00+0000",
        "underlying_asset": "BTC",
        "collateral_asset": "BTC",
        "derivative_type": "options_contract",
        "open_interest": null,
        "is_next_day": false,
        "multiplier": 100,
        "type": "call",
        "is_ecp_only": false
      },
      {
        "id": 108,
        "label": "BTC-Mini-25AUG2021-300000-Put",
        "name": null,
        "is_call": false,
        "active": true,
        "strike_price": 30000000,
        "min_increment": 1,
        "date_live": "2021-02-01 05:00:00+0000",
        "date_expires": "2021-02-19 21:00:00+0000",
        "date_exercise": "2021-02-19 22:00:00+0000",
        "underlying_asset": "BTC",
        "collateral_asset": "USD",
        "derivative_type": "options_contract",
        "open_interest": null,
        "is_next_day": false,
        "multiplier": 100,
        "type": "put",
        "is_ecp_only": false
      },
      {
        "id": 109,
        "label": "BTC-Mini-25AUG2021-Swap",
        "name": null,
        "is_call": null,
        "active": true,
        "strike_price": null,
        "min_increment": 1,
        "date_live": "2021-02-01 05:00:00+0000",
        "date_expires": "2021-02-19 21:00:00+0000",
        "date_exercise": "2021-02-19 22:00:00+0000",
        "underlying_asset": "BTC",
        "collateral_asset": "BTC",
        "derivative_type": "day_ahead_swap",
        "open_interest": null,
        "is_next_day": false,
        "multiplier": 100,
        "is_ecp_only": false
      },
      {
        "id": 110,
        "label": "BTC-Mini-25AUG2021-Future",
        "name": null,
        "is_call": null,
        "active": true,
        "strike_price": null,
        "min_increment": 1,
        "date_live": "2021-02-01 05:00:00+0000",
        "date_expires": "2021-02-19 21:00:00+0000",
        "date_exercise": null,
        "underlying_asset": "BTC",
        "collateral_asset": "BTC",
        "derivative_type": "future_contract",
        "open_interest": null,
        "is_next_day": false,
        "multiplier": 100,
        "is_ecp_only": false
      }
    ],
    "meta": {
      "total_count": 4,
      "next": null,
      "previous": null,
      "limit": 1000,
      "offset": 0
    }
  });
});
// Returns a list of contracts that you have traded.
app.get('/trading/contracts/traded', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 107,
        "label": "BTC-Mini-25AUG2021-300000-Call",
        "date_expires": "2021-02-19 21:00:00+0000"
      },
      {
        "id": 108,
        "label": "BTC-Mini-25AUG2021-300000-Put",
        "date_expires": "2021-02-19 21:00:00+0000"
      },
      {
        "id": 109,
        "label": "BTC-Mini-25AUG2021-Swap",
        "date_expires": "2021-02-19 21:00:00+0000"
      },
      {
        "id": 110,
        "label": "BTC-Mini-25AUG2021-Future",
        "date_expires": "2021-02-19 21:00:00+0000"
      }
    ],
    "meta": {
      "total_count": 4,
      "next": null,
      "previous": null,
      "limit": 1000,
      "offset": 0
    }
  });
});
// Returns contract details for a single contract ID.
app.get('/trading/contracts/:id', async (req,res) => {
  // future contract
  res.json({
    "data": {
      "id": 110,
      "label": "BTC-Mini-25AUG2021-Future",
      "name": null,
      "is_call": null,
      "active": true,
      "strike_price": null,
      "min_increment": 1,
      "date_live": "2021-02-01 05:00:00+0000",
      "date_expires": "2021-02-19 21:00:00+0000",
      "date_exercise": null,
      "underlying_asset": "BTC",
      "collateral_asset": "BTC",
      "derivative_type": "future_contract",
      "open_interest": null,
      "is_next_day": false,
      "multiplier": 100,
      "is_ecp_only": false
    }
  });
});
// Returns your position for a given contract.
app.get('/trading/contracts/:id/position', async (req,res) => {
  res.json({
    "data": {
      "id": 16141,
      "size": 55,
      "type": "long",
      "assigned_size": 0,
      "exercise_instruction": null,
      "contract": {
        "id": 107,
        "label": "BTC-Mini-25AUG2021-300000-Call",
        "name": null,
        "is_call": true,
        "active": true,
        "strike_price": 30000000,
        "min_increment": 1,
        "date_live": "2021-02-01 05:00:00+0000",
        "date_expires": "2021-02-19 21:00:00+0000",
        "date_exercise": "2021-02-19 22:00:00+0000",
        "underlying_asset": "BTC",
        "collateral_asset": "BTC",
        "derivative_type": "options_contract",
        "open_interest": null,
        "is_next_day": false,
        "multiplier": 100,
        "type": "call",
        "is_ecp_only": false
      },
      "has_settled": false
    }
  });
});
// Snapshot information about the current best bid/ask, 24h volume, and last trade.
app.get('/trading/contracts/:id/ticker', async (req,res) => {
  res.json({
    "data": {
      "bid": 10000,
      "ask": 20000,
      "volume_24h": 1000,
      "last_trade": {
        "id": 123,
        "price": 15000,
        "size": 10,
        "time": "2021-05-21T22:13:39.827109Z"
      },
      "time": "2021-05-21T22:14:00.827109Z"
    }
  });
});

/**
 * Positions
 */
app.get('/trading/positions', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 16141,
        "size": 55,
        "type": "long",
        "assigned_size": 0,
        "exercise_instruction": null,
        "contract": {
          "id": 107,
          "label": "BTC-Mini-25AUG2021-300000-Call",
          "name": null,
          "is_call": true,
          "active": true,
          "strike_price": 30000000,
          "min_increment": 1,
          "date_live": "2021-02-01 05:00:00+0000",
          "date_expires": "2021-02-19 21:00:00+0000",
          "date_exercise": "2021-02-19 22:00:00+0000",
          "underlying_asset": "BTC",
          "collateral_asset": "BTC",
          "derivative_type": "options_contract",
          "open_interest": null,
          "is_next_day": false,
          "multiplier": 100,
          "type": "call",
          "is_ecp_only": false
        },
        "has_settled": false
      },
      {
        "id": 16142,
        "size": -55,
        "type": "short",
        "assigned_size": 0,
        "exercise_instruction": null,
        "contract": {
          "id": 107,
          "label": "BTC-Mini-25AUG2021-300000-Call",
          "name": null,
          "is_call": true,
          "active": true,
          "strike_price": 30000000,
          "min_increment": 1,
          "date_live": "2021-02-01 05:00:00+0000",
          "date_expires": "2021-02-19 21:00:00+0000",
          "date_exercise": "2021-02-19 22:00:00+0000",
          "underlying_asset": "BTC",
          "collateral_asset": "BTC",
          "derivative_type": "options_contract",
          "open_interest": null,
          "is_next_day": false,
          "multiplier": 100,
          "type": "call",
          "is_ecp_only": false
        },
        "has_settled": false
      }
    ],
    "meta": {
      "total_count": 2,
      "next": null,
      "previous": null,
      "limit": 40,
      "offset": 0
    }
  });
});
app.get('/trading/positions/:id/trades', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 2827091,
        "contract_id": "77692233",
        "contract_label": "BTC Mini 2021-03-26 Put $5,000",
        "timestamp": "1612995219827108756",
        "filled_price": 25500,
        "filled_size": 1,
        "fee": 15,
        "rebate": 0,
        "premium": 255,
        "created": "2021-02-10T22:13:39.888289Z",
        "order_type": "customer_limit_order",
        "order_id": "56abdd42d38a4183ae52406107d586da",
        "state": null,
        "status_type": "201",
        "side": "bid",
        "execution_time": "2021-02-10T22:13:39.827109Z"
      }
    ],
    "meta": {
      "total_count": 1,
      "next": null,
      "previous": null,
      "limit": 40,
      "offset": 0
    }
  });
});

/**
 * Trades
 */
app.get('/trading/trades', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 2827091,
        "contract_id": "77692233",
        "contract_label": "BTC Mini 2021-03-26 Put $5,000",
        "timestamp": "1612995219827108756",
        "filled_price": 25500,
        "filled_size": 1,
        "fee": 15,
        "rebate": 0,
        "premium": 255,
        "created": "2021-02-10T22:13:39.888289Z",
        "order_type": "customer_limit_order",
        "order_id": "56abdd42d38a4183ae52406107d586da",
        "state": null,
        "status_type": "201",
        "side": "bid",
        "execution_time": "2021-02-10T22:13:39.827109Z"
      }
    ],
    "meta": {
      "total_count": 1,
      "next": null,
      "previous": null,
      "limit": 40,
      "offset": 0
    }
  });
});
app.get('/trading/trades/global', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 2827091,
        "contract_id": "77692233",
        "order_type": "customer_limit_order",
        "filled_price": 25500,
        "filled_size": 1,
        "timestamp": "1612995219827108756",
        "contract_label": "BTC Mini 2021-03-26 Put $5,000",
        "side": null,
        "mpid": null
      }
    ],
    "meta": {
      "total_count": 1,
      "next": null,
      "previous": null,
      "limit": 40,
      "offset": 0
    }
  });
});

/**
 * Transactions
 */
app.get('/funds/transactions', async (req,res) => {
  res.json({
    "data": [
      {
        "id": 433171,
        "created": "2020-11-10T20:13:42.302299Z",
        "last_updated": "2020-11-10T20:13:42.805625Z",
        "amount": 100000,
        "debit_pre_balance": 100000,
        "debit_post_balance": 0,
        "credit_pre_balance": null,
        "credit_post_balance": null,
        "debit_account_field_name": "bitcoin_network_transaction_fee_locked_amount",
        "credit_account_field_name": "available_balance",
        "transaction_type": "fee_transaction",
        "settlement_id": null,
        "asset": "BTC",
        "state": "executed",
        "group_id": "1",
        "deposit_notice_id": null,
        "trade_id": null,
        "net_change": -100000
      },
      {
        "id": 433170,
        "created": "2020-11-10T20:13:42.283865Z",
        "last_updated": "2020-11-10T20:13:42.796567Z",
        "amount": 100000000,
        "debit_pre_balance": 100000000,
        "debit_post_balance": 0,
        "credit_pre_balance": null,
        "credit_post_balance": null,
        "debit_account_field_name": "withdrawal_locked_amount",
        "credit_account_field_name": "available_balance",
        "transaction_type": "withdrawal_transaction",
        "settlement_id": null,
        "asset": "BTC",
        "state": "executed",
        "group_id": "1",
        "deposit_notice_id": null,
        "trade_id": null,
        "net_change": -100000000
      }
    ],
    "meta": {
      "total_count": 2,
      "next": null,
      "previous": null,
      "limit": 40,
      "offset": 0
    }
  });
});
app.get('/funds/balances', async (req,res) => {
  res.json({
    "data": {
      "ETH": {
        "available_balance": 0,
        "position_locked": 0,
        "settlement_locked": 0,
        "deliverable_locked": 0,
        "withdrawal_locked": 0,
        "total": 0
      },
      "BTC": {
        "available_balance": 0,
        "position_locked": 0,
        "settlement_locked": 0,
        "deliverable_locked": 0,
        "withdrawal_locked": 0,
        "total": 0
      },
      "USD": {
        "available_balance": 0,
        "position_locked": 0,
        "settlement_locked": 0,
        "deliverable_locked": 0,
        "withdrawal_locked": 0,
        "total": 0
      }
    }
  });
});

/**
 * Starting Server
 */
const port = 3000; 

app.listen(port, () => {
  init();
  console.log(`Server is listening on port ${port}`);
});

