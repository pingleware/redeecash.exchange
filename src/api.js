"use strict"

const mongoose = require('mongoose');
const Web3 = require('web3');
const OrderBook = require('./orderBook');

const {    
  tokenABI,
  poolABI
} = require('./abi');

// Initialize Web3
const web3 = new Web3('http://127.0.0.1:8545'); // Update with your Ethereum node URL

const contract_owner_wallet = "";


// Define the user schema
const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    wallet: {
        type: String,
        required: true
    },
    tokenBalance: {
        type: Number,
        default: 0,
    },
    kycData: {
        type: String,
        default: '',
    },
});

// Define the transferAgent schema
const transferAgentSchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
      type: String,
      required: true,
      unique: true,
  },
  password: {
      type: String,
      required: true,
  },
  wallet: {
      type: String,
      required: true
  },
  address1: {
      type: String,
      required: false
  },
  address1: {
    type: String,
    required: false
  },
  address2: {
    type: String,
    required: false
  },
  city: {
    type: String,
    required: false
  },
  state: {
    type: String,
    required: false
  },
  zipcode: {
    type: String,
    required: false
  },
  phoneNumber: {
    type: String,
    required: false
  },
});

// Define the token schema
const tokenSchema = new mongoose.Schema({
    name: {
      type: String,
      required: true,
    },
    symbol: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    contractAddress: {
      type: String,
      required: true,
      unique: true,
    },
    abi: {
      type: String,
      require: true,
      unique: true
    },
    secFileNumber: {
      type: String,
      required: true,
      unique: true
    },
    securityType: {
      type: String,
      required: true
    }
});

// Define the support ticket schema
const supportTicketSchema = new mongoose.Schema({
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    subject: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['Open', 'In Progress', 'Closed'],
      default: 'Open',
    },
});

// Define the order schema
const orderSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    tokenSymbol: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['Buy', 'Sell'],
      required: true,
    },
    volume: {
      type: Number,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ['Pending', 'Completed', 'Cancelled'],
      default: 'Pending',
    },
});

// Consolidated Audit Trail schema
const catSchema = new mongoose.Schema({
  senderIMID: {
    type: String,
    required: true,
  },
  routedOrderID: {
    type: String,
    required: true,
  },
  symbol: {
    type: String,
    required: true,
  },
  eventTimestamp: {
    type: String,
    required: true,
  },
  session: {
    type: String,
    required: true,
  },
});

  
// Create the token model
let Token; // = mongoose.model('Token', tokenSchema);

// Create the user model
let User; // = mongoose.model('User', userSchema);

// Create the transfer agent model
let TransferAgent; // = mongoose.model('TransferAgent', transferAgentSchema);

// Create the support ticket model
let SupportTicket; // = mongoose.model('SupportTicket', supportTicketSchema);

// Create the order model
let Order; // = mongoose.model('Order', orderSchema);

// Create the consoldate audit trail model
let CAT;


async function init() {
  // Connect to MongoDB
  mongoose.connect('mongodb://localhost:27017/redeecashexchange', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  // Create the token model
  Token = mongoose.model('Token', tokenSchema);

  // Create the user model
  User = mongoose.model('User', userSchema);

  // Create the transfer agent model
  TransferAgent = mongoose.model('TransferAgent', transferAgentSchema);

  // Create the support ticket model
  SupportTicket = mongoose.model('SupportTicket', supportTicketSchema);

  // Create the order model
  Order = mongoose.model('Order', orderSchema);

  // Create the CAT model
  CAT = mongoose.model('CAT', catSchema);

}

/**
 * User Registration
 * 1. Code to handle user registration
 * 2. Validate email and password
 * 3. Store user information in the database
 * 
 * @param {string} email 
 * @param {string} password 
 * @param {number} access 0=non-accredited;1=accredited;2=affililate;4=broker-dealer
 * @returns {object} status 
 */
async function registerUser(name, email, password, wallet, access) {
  try {
      // Create a new user instance
      const user = new User({ name, email, password, wallet, access });
  
      // Save the user to the database
      await user.save();

      return { success: true, message: 'User registered successfully' };
  } catch(error) {
    console.error(error);
    return { success: false, message: 'Error registering user', error: error };
  }
  /*
  mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
    const contractAddress = token[0].contractAddress;
    const abi = token[0].abi;
    const contract = new web3.eth.Contract(abi, contractAddress);

    try {
      // Validate email and password
      if (!validateEmail(email)) {
        return { success: false, message: 'Invalid email format' };
      }
  
      if (!validatePassword(password)) {
        return {
          success: false,
          message: 'Password must be at least 8 characters long',
        };
      }
  
      // Create a new user instance
      const user = new User({ email, password, wallet });
  
      // Save the user to the database
      await user.save();

      await contract.methods.addInvestor({investor: wallet, investor_type: access}).call({from: this.transferAgent});
  
      return { success: true, message: 'User registered successfully' };
    } catch (error) {
      return { success: false, message: 'Error registering user' };
    }    
  });
  */
}

async function updateTokenContractAddress(symbol, tokenAddress) {
  try {
    const status = await Token.updateOne({contractAddress: tokenAddress}).where('symbol').eq(symbol);
    console.log(status);
    return { status: true, message: status };
  } catch(error) {
    return { status: false, error: error };
  }
}

async function addUserToToken(tokenAddress, userAddress) {

  //const contract = new web3.eth.Contract(JSON.parse(abi), tokenAddress);
  //const transferAgent = '0xB72621c155fB0d8Dcc9b65301FeB35618aF3d8Eb';
  //await contract.methods.addTransferAgent(transferAgent).call({from: '0x5EaF72deD2e4E255C228f9070501974D3572c5d4'});
  //await contract.methods.addInvestor(userAddress, access).call({from: transferAgent});

  return {status: true, message: 'investor added successfully'};
}

async function registerTransferAgent(poolContract,tokenAddress,name,email,password,wallet) {
  try {
    // Validate email and password
    //if (!validateEmail(email)) {
    //  return { success: false, message: 'Invalid email format' };
   // }

    //if (!validatePassword(password)) {
    //  return {
    //    success: false,
    //    message: 'Password must be at least 8 characters long',
    //  };
    //}

    // Create a new user instance
    const transferAgent = new TransferAgent({ name, email, password, wallet });

    // Save the user to the database
    const status1 = await transferAgent.save();
    console.log(status1);

    const contract = new web3.eth.Contract(JSON.parse(tokenABI), tokenAddress);
    const status = await contract.methods.addTransferAgent(wallet).call({from: poolContract});
    console.log(status);
    return { success: true, message: 'Transfer Agent registered successfully', status: status };
  } catch (error) {
    return { success: false, message: 'Error registering Transfer Agent ', error: error };
  }    
}


async function addTransferAgentToToken(symbol,transferAgent) {
  try {
    const token = await Token.find({}).where('symbol').eq(symbol).exec();
    if (token.length > 0) {
      //console.log(token)
      const tokenAddress = token[0].contractAddress;
      console.log(`tokenAddress: ${tokenAddress}`);
      const contract = await new web3.eth.Contract(JSON.parse(tokenABI), tokenAddress);
      console.log(await contract.methods.symbol())
      //console.log(contract.methods)
      ///await contract.methods.getOwner().call().then(function(owner) {
      //  console.log(owner);
      //  return tokenAddress;  
      //});
      //const owner = await contract.methods.getOwner().call();
      //console.log(owner);
    }
    //const contract = new web3.eth.Contract(JSON.parse(poolABI), poolContract);
    //const status = await contract.methods.addTransferAgent(symbol,transferAgent).call({from: owner});
    //console.log(status);
    //return { success: true, message: 'Transfer Agent added to token successfully', status: status };
  } catch(error) {
    return { success: false, message: 'Error adding Transfer Agent to token', error: error };
  }
}

/**
 * KYC Verification
 * 1. Code to handle KYC verification
 * 2. Verify user identity information using a third-party KYC service
 * 3. Update user's KYC status in the database
 */
async function performKYCVerification(userId, kycData) {
    try {
        const user = await User.findById(userId).exec();
    
        if (user) {
          if (user.emailVerified) {
            console.log('KYC Verification: Email is verified');
            // Additional KYC verification steps can be added here
            // ...
    
            // Update KYC data in the user object
            user.kycData = kycData;
            await user.save();
    
            return { success: true, message: 'Verification successful' };
          } else {
            console.log('KYC Verification: Email is not verified');
            return { success: false, message: 'KYC Verification: Email is not verified' };
          }
        } else {
          console.log('User not found');
          return { success: false, message: 'User not found' };
        }
    } catch (error) {
        console.error('Error performing KYC verification:', error);
        return { success: false, message: `Error performing KYC verification: ${error}` };
    }
}
  
/**
 * Token Listings
 * 1. Code to handle token listing application
 * 2. Validate token details
 * 3. Store token listing information in the database
 * 
 * Example Usage:
 * -------------
 * const newToken = {
 *   name: 'MyToken',
 *   symbol: 'MTK',
 *   description: 'My custom token',
 *   contractAddress: '0x123456789abcdef',
 *   abi; '',
 *   secFileNumber: '',
 *   securityType: ''
 * };
 * 
 * applyForTokenListing(newToken)
 *   .then((result) => console.log(result))
 *   .catch((error) => console.error(error));
 * 
 * @param {*} tokenDetails 
 * @returns 
 */
async function applyForTokenListing(tokenDetails) {
    try {
      var token = new Token(JSON.parse(tokenDetails));
      const status = await token.save();
      console.error(status);
      return { success: true, message: `listing applied successfully`, status: status };
    } catch (error) {
        return { success: false, message: 'Error applying for token listing', error: error };
    }
}

async function createTokenListing(poolContract,offeringType,secFileNumber,name,symbol,tokens,price,owner,ownerPrivateKey) {
  try {
    const account = owner; // Replace with your Ethereum account address
    const privateKey = ownerPrivateKey; // Replace with your account's private key

    const contract = new web3.eth.Contract(JSON.parse(poolABI), poolContract);

    await contract.methods.createToken(name,symbol,tokens,price).call({from: account});
    /*
    const txObject = contract.methods.createToken(name,symbol,tokens,price); // Replace with your contract's function name and arguments
    console.log(txObject)

    const gas = await txObject.estimateGas();
    console.log(`Gas: ${gas}`)
    const gasPrice = await web3.eth.getGasPrice();
    console.log(`Gas Price: ${gasPrice}`)

    const tx = txObject.send({
      from: account,
      gas: gas,
      gasPrice: gasPrice,
    });
    console.log(`tx: ${tx}`)

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    console.log(`singedTX: ${signedTx}`)

    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log(`receipt: ${receipt}`)
    */
    const tokenAddress = await contract.methods.tokenContracts(symbol); 
    console.log(`tokenAddress: ${tokenAddress}`)
    const tokenDetails = {name: name, symbol: symbol, description: name, contractAddress: tokenAddress, abi: btoa(abi), secFileNumber: secFileNumber, secuortyType: offeringType};
    const token = Token(tokenDetails);
    const result = await  token.save();

    return {status: true, receipt: receipt, token: token};
  } catch (error) {
    console.error(error);
    return {status: false, error: error};
  }
}
  
/**
 * Trading
 * 1. Code to handle order placement
 * 2. Validate order details
 * 3. Execute order and update user's balances in the database
 * 
 * @param {*} userId 
 * @param {*} orderDetails 
 * @returns 
 */
async function placeOrder(userId, orderDetails) {
    try {
        // Create a new order instance
        orderDetails.userId = userId;
        const order = new Order(orderDetails);
    
        // Validate the order
        // You can add your own validation logic here
        if (order.type === 'Buy' || order.type === 'Sell' && order.quantity <= 0) {
          return { success: false, message: 'Invalid order quantity' };
        }
    
        // For simplicity, we'll just save the order to the database
        await order.save();

        // Process the order
        // You can add your own order processing logic here
        // OrderBook
        const OrderBook = require("./orderBook");
        const orderBook = new OrderBook(orderDetails.tokenSymbol);

        orderBook.matchOrders();

    
        return { success: true, message: 'Order placed successfully', orderbook: orderBook.printOrderBook() };
    } catch (error) {
        return { success: false, message: 'Error placing the order' };
    }
}
  
/**
 * Wallet Integration
 * 1. Code to handle token deposits
 * 2. Validate user's wallet address
 * 3. Update user's token balance in the database
 * 
 * @param {*} userId 
 * @param {*} amount 
 * @param {*} token 
 * @returns 
 */
async function depositTokens(userId, amount, token) {
    try {
        // Find the user by their ID
        const user = await User.findById(userId);
    
        if (!user) {
          return { success: false, message: 'User not found' };
        }

        // Set the contract address
        const contractAddress = token.contractAddress;

        // Load the contract ABI
        const abi = token.abi;

        // Create a contract instance
        const contract = new web3.eth.Contract(abi, contractAddress);

        try {
          const result = await contract.methods.mint(user.wallet, amount).send({ from: contract_owner_wallet });
          const balance = await contract.methods.balanceOf(address).call();

          // Update the token balance
          user.tokenBalance = balance;
      
          // Save the updated user in the database
          await user.save();

          return { success: true, message: 'Tokens deposited successfully', txHash: result.transactionHash };
        } catch (error) {
          res.status(500).json({ error: 'Failed to mint tokens' });
        }    
    } catch (error) {
        return { success: false, message: 'Error depositing tokens' };
    }
}

/**
 * withdrawTokens
 * 1. Code to handle token withdrawals
 * 2. Validate user's wallet address and available balance
 * 3. Update user's token balance in the database
 * 
 * @param {*} userId 
 * @param {*} amount 
 * @param {*} token 
 * @returns 
 */
async function withdrawTokens(userId, amount, token) {
    try {
        // Find the user by their ID
        const user = await User.findById(userId);
    
        if (!user) {
          return { success: false, message: 'User not found' };
        }
    
        // Validate withdrawal amount
        if (user.tokenBalance < amount) {
          return { success: false, message: 'Insufficient token balance' };
        }


        // Set the contract address
        const contractAddress = token.contractAddress;

        // Load the contract ABI
        const abi = token.abi;

        // Create a contract instance
        const contract = new web3.eth.Contract(abi, contractAddress);
    
        try {
          const result = await contract.methods.burn(amount).send({ from: user.wallet });
          const balance = await contract.methods.balanceOf(address).call();

          // Update the token balance
          user.tokenBalance = balance;
      
          // Save the updated user in the database
          await user.save();
          return { success: true, message: 'Tokens withdrawn successfully', txHash: result.transactionHash };
        } catch (error) {
          res.status(500).json({ error: 'Failed to burn tokens' });
        }
    } catch (error) {
        return { success: false, message: 'Error withdrawing tokens' };
    }
}
  
/**
 * FIX API
 * 1. Code to handle incoming FIX messages
 * 2. Parse the message and perform the appropriate action (place order, cancel order, etc.)
 * 
 * @param {*} message 
 */
async function processFIXMessage(fixMessage) {
    const fields = fixMessage.split('|');

    const message = {};
    for (const field of fields) {
        const [tag, value] = field.split('=');
        message[tag] = value;
    }
    console.log('Received FIX Message:');
    console.log(message);
    
    /**
     * New Order (Single) Message:
     * 8=FIX.4.4|9=146|35=D|34=1|49=CLIENT1|52=20230527-10:30:00.123|56=REDEECASH.EXCHANGE|55=SYM1|11=ORDER1|54=1|38=100|40=2|44=25.00|59=0|10=231|
     * 
     * Execution Report Message:
     * 8=FIX.4.4|9=156|35=8|34=2|49=REDEECASH.EXCHANGE|52=20230527-10:30:00.567|56=CLIENT1|37=EXEC1|17=123456|20=0|39=2|55=SYM1|31=25.00|32=100|14=2500.00|151=100|6=0|60=20230527-10:30:00|10=182|
     * 
     * Order Cancel Request Message:
     * 8=FIX.4.4|9=125|35=F|34=3|49=CLIENT1|52=20230527-10:30:00.888|56=REDEECASH.EXCHANGE|41=CANCEL1|37=ORDER1|11=ORDER1|55=SYM1|10=191|
     * 
     */

    switch(message[35]) {
      case 'D': // New Order (Single) Message
        {
          const client = message[40];
          var query = { wallet: client };
          mongoose.collection("User").find(query).toArray( async function(err, result) {
            const tokenSymbol = message[55];
            const orderType = message[54]; // 1=Buy,2=Sell
            const orderDetails = {
              userId: result[0], // client
              tokenSymbol: tokenSymbol, // token symbol
              type: (orderType == 1 ? 'Buy' : 'Sell'),  // order type
              volume: Number(message[38]),
              price: Number(message[44]),
              status: 'Pending'
            }
            const order = new Order(orderDetails);
            // Validate the order
            // You can add your own validation logic here
            if (order.type === 'Buy' || order.type === 'Sell' && order.quantity <= 0) {
              return { success: false, message: 'Invalid order quantity' };
            }
        
            // For simplicity, we'll just save the order to the database
            await order.save();
  
            // Process the order
            // You can add your own order processing logic here
            // OrderBook
            const OrderBook = require("./orderBook");
            const orderBook = new OrderBook(tokenSymbol);
  
            orderBook.matchOrders();
        
            return { success: true, message: 'Order placed successfully', orderbook: orderBook.printOrderBook() };  
          });
        }
        break;
      case '8': // Execution Report
        {
          /**
           * Execution Report Message:
           * 8=FIX.4.4|9=156|35=8|34=2|49=REDEECASH.EXCHANGE|52=20230527-10:30:00.567|56=CLIENT1|37=EXEC1|17=123456|20=0|39=2|55=SYM1|31=25.00|32=100|14=2500.00|151=100|6=0|60=20230527-10:30:00|10=182|
           * 
           * 35=8: Message type is Execution Report.
           * 49=REDEECASH.EXCHANGE: Sender ID.
           * 56=CLIENT1: Target ID.
           * 37=EXEC1: Execution ID.
           * 17=123456: Order ID.
           * 39=2: Execution type (2 for Fill).
           * 55=SYM1: Symbol or instrument.
           * 31=25.00: Last price.
           * 32=100: Last quantity.
           * 14=2500.00: Cumulative quantity.
           * 151=100: Leaves quantity.
           * 6=0: Average price.
           * 60=20230527-10:30:00: Transact time.
           * 10=182: Checksum.
           * 
           */

          const transactionHash = message[37];
          const OrderBook = require("./orderBook");
          const orderBook = new OrderBook(tokenSymbol);
          return orderBook.getTransactionByHash(transactionHash);
        }
        break;
      case 'F': // Order Cancel Request
        {
          /**
           * Order Cancel Request Message:
           * 8=FIX.4.4|9=125|35=F|34=3|49=CLIENT1|52=20230527-10:30:00.888|56=REDEECASH.EXCHANGE|41=CANCEL1|37=ORDER1|11=ORDER1|55=SYM1|10=191|
           */
          const tokenSymbol = message[55];
          const orderId = message[37];
          const OrderBook = require("./orderBook");
          const orderBook = new OrderBook(tokenSymbol);
          if (orderBook.cancelOrder(orderId)) {
            return { success: true, message: 'Order cancelled successfully', orderbook: orderBook.printOrderBook() };
          } else {
            return { success: false, message: `Order ${orderId} not cancelled`, orderbook: orderBook.printOrderBook() };
          }
        }
        break;
    }

}
  
/**
 * Security and Compliance
 * 1. Code to perform security checks
 * 2. Verify user's identity and transaction details
 * 3. Check for suspicious activities and comply with AML regulations
 * 
 * @param {*} userId 
 * @param {*} transaction 
 * @returns 
 */
async function performSecurityChecks(userId, transaction) {
    try {
        // Check if the user is authenticated or authorized
        // You can implement your own authentication and authorization logic here
        // For simplicity, we'll assume the user is already authenticated and authorized
    
        // Check if the user has passed KYC (Know Your Customer) verification
        const user = await User.findById(userId);
    
        if (!user) {
          return { success: false, message: 'User not found' };
        }
    
        if (!user.kycVerified) {
          return { success: false, message: 'KYC verification required' };
        }
    
        // Check if the user has passed AML (Anti-Money Laundering) screening
        // You can implement your own AML screening logic here
        // For simplicity, we'll assume the user has passed AML screening

        // Additional checks based on transaction type
        if (transaction.transactionType === 'withdrawal') {
            // Check if the user has sufficient token balance for the withdrawal
            if (user.tokenBalance < transaction.transactionAmount) {
                return { success: false, message: 'Insufficient token balance' };
            }
  
            // Add any other checks specific to the withdrawal transaction
        } else if (transaction.transactionType === 'transfer') {
            // Add any checks specific to the token transfer transaction
        }
    
        return { success: true, message: 'Security checks passed' };
    } catch (error) {
        return { success: false, message: 'Error performing security checks' };
    }
}
  
/**
 * Testing and Deployment
 * 1. Code to execute unit tests, integration tests, and end-to-end tests
 * 2. Test the functionality and stability of the exchange components
 */
function runTests() {
    
}
  
/**
 * Ongoing Maintenance and Support
 * 1. Code to handle customer support tickets
 * 2. Analyze the ticket and provide appropriate assistance or solutions
 * 
 * @param {*} ticketDetails 
 * @returns 
 */
async function handleCustomerSupportTicket(ticketDetails) {
    try {
        // Create a new support ticket instance
        const ticket = new SupportTicket(ticketDetails);
    
        // Save the support ticket to the database
        await ticket.save();
    
        return { success: true, message: 'Support ticket handled successfully' };
    } catch (error) {
        return { success: false, message: 'Error handling support ticket' };
    }
}

async function getTokenQuote(tokenSymbol) {
    try {
      const orderBook = new OrderBook();
      const quote = orderBook.getQuote()

      return { success: true, quote: quote };
    } catch (error) {
      return { success: false, message: 'Error fetching token quote' };
    }
}

async function getOrderBook(tokenSymbol) {
  try {
    const orderBook = new OrderBook(tokenSymbol);
    return { success: orderBook.printOrderBook() };
  } catch(error) {
    return { success: false, message: error };
  }
}

module.exports = {
    init,
    updateTokenContractAddress,
    registerUser,
    addUserToToken,
    registerTransferAgent,
    addTransferAgentToToken,
    performKYCVerification,
    applyForTokenListing,
    createTokenListing,
    placeOrder,
    depositTokens,
    withdrawTokens,
    processFIXMessage,
    performSecurityChecks,
    runTests,
    handleCustomerSupportTicket,
    getTokenQuote,
    getOrderBook
}