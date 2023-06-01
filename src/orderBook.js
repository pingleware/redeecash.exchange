"use strict"

/**
 * Example usage
 * -------------
 * 
 * const orderBook = new OrderBook();
 * 
 * orderBook.addBid({ price: 10, volume: 5 });
 * orderBook.addBid({ price: 12, volume: 3 });
 * orderBook.addBid({ price: 8, volume: 7 });
 * 
 * orderBook.addAsk({ price: 11, volume: 4 });
 * orderBook.addAsk({ price: 9, volume: 6 });
 * orderBook.addAsk({ price: 13, volume: 2 });
 * 
 * orderBook.printOrderBook();
 * 
 * orderBook.matchOrders();
 * 
 * orderBook.printOrderBook();
 * 
 */


const mongoose = require('mongoose');
const Web3 = require('web3');
// Initialize Web3
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545')); // Update with your Ethereum node URL

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/redeecashexchange', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});


class OrderBook {
    constructor(tokenSymbol, transferAgent="") {
        this.tokenSymbol = tokenSymbol;
        this.transferAgent = transferAgent;
        this.bids[this.tokenSymbol] = []; // Array to store buy orders
        this.asks[this.tokenSymbol] = []; // Array to store sell orders
        mongoose.collection("Order").find({}, function(err, result) {
            if (result.tokenSymbol === tokenSymbol && result.type === 'Buy') {
                this.bids[this.tokenSymbol].push(result);
            } else if (result.tokenSymbol === tokenSymbol && result.type === 'Sell') {
                this.asks[this.tokenSymbol].push(result);
            }
        });
        this.sortBidsByPriceDesc();
        this.sortAsksByPriceAsc();
    }

    // create a listing
    static async createTokenListing(offertype,secFileNumber,name,symbol,tokens,price,ownerId) {
        var abi = `[
            {
                "inputs": [],
                "stateMutability": "nonpayable",
                "type": "constructor"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "symbol",
                        "type": "string"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    }
                ],
                "name": "createToken",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "name": "tokenContracts",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            }
        ]`;

        var tokenABI = `[
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_name",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_symbol",
                        "type": "string"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "constructor"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "tokenOwner",
                        "type": "address"
                    },
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "spender",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "Approval",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    },
                    {
                        "indexed": false,
                        "internalType": "string",
                        "name": "reason",
                        "type": "string"
                    }
                ],
                "name": "Disapproval",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": false,
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    },
                    {
                        "indexed": false,
                        "internalType": "bool",
                        "name": "buy",
                        "type": "bool"
                    }
                ],
                "name": "Request",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "from",
                        "type": "address"
                    },
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "Transfer",
                "type": "event"
            },
            {
                "inputs": [],
                "name": "CUSIP",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "DESCRIPTION",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "MAX_OFFERING",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "MAX_OFFERING_SHARES",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "RESTRICTED_SECURITY",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "SEC_FILENUMBER",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "YEAR",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "_totalSupply",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "investor_type",
                        "type": "uint256"
                    }
                ],
                "name": "addInvestor",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "transferAgent",
                        "type": "address"
                    }
                ],
                "name": "addTransferAgent",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "tokenOwner",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "spender",
                        "type": "address"
                    }
                ],
                "name": "allowance",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "remaining",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "spender",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "approve",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "from",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "approveTransaction",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "tokenOwner",
                        "type": "address"
                    }
                ],
                "name": "balanceOf",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "balance",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_amount",
                        "type": "uint256"
                    }
                ],
                "name": "burn",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "decimals",
                "outputs": [
                    {
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    },
                    {
                        "internalType": "bool",
                        "name": "buy",
                        "type": "bool"
                    },
                    {
                        "internalType": "string",
                        "name": "reason",
                        "type": "string"
                    }
                ],
                "name": "disapprove",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "getInvestors",
                "outputs": [
                    {
                        "internalType": "address[]",
                        "name": "",
                        "type": "address[]"
                    },
                    {
                        "internalType": "address[]",
                        "name": "",
                        "type": "address[]"
                    },
                    {
                        "internalType": "address[]",
                        "name": "",
                        "type": "address[]"
                    },
                    {
                        "internalType": "address[]",
                        "name": "",
                        "type": "address[]"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "getMaxOffering",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    },
                    {
                        "internalType": "bool",
                        "name": "buy",
                        "type": "bool"
                    }
                ],
                "name": "getRequested",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "getTransferAgents",
                "outputs": [
                    {
                        "internalType": "address[]",
                        "name": "",
                        "type": "address[]"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_amount",
                        "type": "uint256"
                    }
                ],
                "name": "mint",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "name",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "owner",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "requestBuy",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "requestSell",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    }
                ],
                "name": "resetBuy",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "investor",
                        "type": "address"
                    }
                ],
                "name": "resetSell",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "cusip",
                        "type": "string"
                    }
                ],
                "name": "setCUSIP",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "value",
                        "type": "uint256"
                    }
                ],
                "name": "setMaxOffering",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "value",
                        "type": "uint256"
                    }
                ],
                "name": "setMaxShares",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "fileNumber",
                        "type": "string"
                    }
                ],
                "name": "setSECFilenumber",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "symbol",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "",
                        "type": "string"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "totalSupply",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "transfer",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "from",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "tokens",
                        "type": "uint256"
                    }
                ],
                "name": "transferFrom",
                "outputs": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]`;

        try {
            switch(offertype) {
                case 'REGAT1':
                    {
                        var contractAddress = "0x903a766aF1cE4662112DF8D1572aCD5dEA506b48";
                    }
                    break;
                case '506B':
                    {
                        var contractAddress = "0x3a4e3341C285F0d69a70d8baF610bCD8dEA55F86";
                    }
                    break;
                case '506C':
                    {
                        var contractAddress = "0x2640671f82aD2DC11A9F6128248532a1C3D72Bf2";
                    }
                    break;
            }
            const contract = new web3.eth.Contract(JSON.parse(abi), contractAddress);
            await contract.methods.createToken(name,symbol,tokens,price).call({from: ownerId});
            const tokenAddress = await contract.methods.tokenContracts(symbol); 
            console.log(tokenAddress);
            //const tokenContract = new web3.eth.Contract(JSON.parse(tokenABI), tokenAddress);
            //await tokenContract.methods.setSECFilenumber(secFileNumber).call({from: ownerId});
            return {tokenAddress, tokenABI};    
        } catch(error) {
            console.error(error);
        }
    }
    
    // Add a buy order to the order book
    addBid(order) {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            const contractAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, contractAddress);

            await contract.methods.requestBuy({tokens: order.volume, from: order.userId }).call({from: order.userId.wallet});

            this.bids[this.tokenSymbol].push(order);
            this.sortBidsByPriceDesc();    
        });
      }
    
    // Add a sell order to the order book
    addAsk(order) {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            const contractAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, contractAddress);

            await contract.methods.requestSell({tokens: order.volume, from: order.userId }).call({from: order.userId.wallet});

            this.asks[this.tokenSymbol].push(order);
            this.sortAsksByPriceAsc();
        });
    }
    
    // Sort buy orders by price in descending order
    sortBidsByPriceDesc() {
      this.bids[this.tokenSymbol].sort((a, b) => b.price - a.price);
    }
    
    // Sort sell orders by price in ascending order
    sortAsksByPriceAsc() {
      this.asks[this.tokenSymbol].sort((a, b) => a.price - b.price);
    }
    
    // Get the highest bid (buy order) price
    getHighestBidPrice() {
      if (this.bids[this.tokenSymbol].length > 0) {
        return this.bids[this.tokenSymbol][0].price;
      }
      return null;
    }
    
    // Get the lowest ask (sell order) price
    getLowestAskPrice() {
      if (this.asks[this.tokenSymbol].length > 0) {
        return this.asks[this.tokenSymbol][0].price;
      }
      return null;
    }
    
    // Match buy and sell orders and execute trades
    async matchOrders() {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            const contractAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, contractAddress);

            while (this.bids[this.tokenSymbol].length > 0 && this.asks[this.tokenSymbol].length > 0) {
                const highestBid = this.bids[this.tokenSymbol][0];
                const lowestAsk = this.asks[this.tokenSymbol][0];
        
                if (highestBid.price >= lowestAsk.price) {
                    const tradePrice = lowestAsk.price;
                    const tradeVolume = Math.min(highestBid.volume, lowestAsk.volume);

                    try {
                        // Invoke token contract transfer method
                        /**
                         * 1. Get token contract address from the tokenSymbol
                         * 2. if highestBid.type == 'Buy' and lowestAsk.type == 'Sell', transfer tradeVolume from lowestAsk.userId wallet to highestBid.userId wallet
                         * 3. If highestBid.type == 'Sell' and lowestAsk.type == 'Buy', transfer tradeVolume from highestBid.userId wallet to lowestAsk.userId wallet 
                         */
                        console.log(`Trade executed at price ${tradePrice}, volume ${tradeVolume}`);

                        if (highestBid.type == 'Buy' && lowestAsk.type == 'Sell' && highestBid.status == 'Pending' && lowestAsk.status == 'Pending') {
                            // invoke approveTransaction
                            await contract.methods.approveTransaction({from: highestBid.userId.wallet, to: lowestAsk.userId.wallet, tokens: tradeVolume }).call({from: this.transferAgent});
                            // invoke transferFrom                            
                            await contract.methods.transferFrom({ from: highestBid.userId.wallet, to: lowestAsk.userId.wallet, amount: tradeVolume});
                            // update balance_highestBid user balance
                            const balance_highestBid = await contract.methods.balanceOf(highestBid.userId.wallet).call();
                            // Update the token balance
                            highestBid.userId.tokenBalance = balance_highestBid;
                            // Save the updated user in the database
                            await highestBid.userId.save();
                            // update balance_lowestAsk user balance
                            const balance_lowestAsk = await contract.methods.balanceOf(lowestAsk.userId.wallet).call();
                            // Update the token balance
                            lowestAsk.userId.tokenBalance = balance_lowestAsk;
                            // Save the updated user in the database
                            await lowestAsk.userId.save();
                        } else if (highestBid.type == 'Sell' && lowestAsk.type == 'Buy' && highestBid.status == 'Pending' && lowestAsk.status == 'Pending') {
                            // invoke approveTransaction
                            await contract.methods.approveTransaction({from: lowestAsk.userId.wallet, to: highestBid.userId.wallet, tokens: tradeVolume }).call({from: this.transferAgent});
                            // invoke transferFrom                            
                            await contract.methods.transferFrom({ from: lowestAsk.userId.wallet, to: highestBid.userId.wallet, amount: tradeVolume});
                            // update balance_highestBid user balance
                            const balance_highestBid = await contract.methods.balanceOf(highestBid.userId.wallet).call();
                            // Update the token balance
                            highestBid.userId.tokenBalance = balance_highestBid;
                            // Save the updated user in the database
                            await highestBid.userId.save();
                            // update balance_lowestAsk user balance
                            const balance_lowestAsk = await contract.methods.balanceOf(lowestAsk.userId.wallet).call();
                            // Update the token balance
                            lowestAsk.userId.tokenBalance = balance_lowestAsk;
                            // Save the updated user in the database
                            await lowestAsk.userId.save();
                        }
                
                        if (highestBid.volume === 0 && highestBid.status == 'Pending') {
                            var query = { _id: highestBid._id };
                            var newValues = { $set: { status: 'Completed' } };
                            mongoose.collection('Order').updateOne(query, newValues, function(err,result){
                                this.bids[this.tokenSymbol].shift();
                            });
                        }
                        if (lowestAsk.volume === 0 && lowestAsk.status == 'Pending') {
                            var query = { _id: lowestAsk._id };
                            var newValues = { $set: { status: 'Completed' } };
                            mongoose.collection('Order').updateOne(query, newValues, function(err,result){
                                this.asks[this.tokenSymbol].shift();
                            });
                        }        
                    } catch(error) {
                        return error;
                    }
                } else {
                    break; // No more matches can be made
                }
            }
        })
    }

    cancelOrder(orderId) {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            // Check bids array for the order ID
            const bidIndex = this.bids[this.tokenSymbol].findIndex((bid) => bid._id === orderId);
            if (bidIndex !== -1) {
                var query = { _id: this.bids[bidIndex]._id };
                var newValues = { $set: { status: 'Cancelled' } };
                mongoose.collection('Order').updateOne(query, newValues, function(err,result){
                    this.bids.splice(bidIndex, 1);
                });
                return true;
            }
        
            // Check asks array for the order ID
            const askIndex = this.asks[this.tokenSymbol].findIndex((ask) => ask._id === orderId);
            if (askIndex !== -1) {
                var query = { _id: this.asks[askIndex]._id };
                var newValues = { $set: { status: 'Cancelled' } };
                mongoose.collection('Order').updateOne(query, newValues, function(err,result){
                    this.asks.splice(askIndex, 1);
                });
                return true;
            }

            return false;
        });
    
        return false; // Order ID not found
    }

    async getTransactionByHash(txHash) {
        try {
            mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
                const contractAddress = token[0].contractAddress;
                const abi = token[0].abi;
                const contract = new web3.eth.Contract(abi, contractAddress);
                const transaction = await contract.getTransaction(txHash);
                return { status: true, transaction: transaction };
            });
        } catch (error) {
          console.error('Failed to fetch transaction:', error);
          return { status: false, message: error };
        }
      }

    // Get a quote with the highest bid price and lowest ask price
    getQuote() {
        const highestBidPrice = this.getHighestBidPrice();
        const lowestAskPrice = this.getLowestAskPrice();

        return {
            bid: highestBidPrice,
            ask: lowestAskPrice,
        };
    }
    
    // Print the current state of the order book
    printOrderBook() {
        var orderBook = {
            bids: this.bids[this.tokenSymbol],
            asks: this.asks[this.tokenSymbol]
        }
        console.log('---- Order Book ----');
        
        console.log('Bids:');
        for (const bid of this.bids[this.tokenSymbol]) {
            console.log(`Price: ${bid.price}, Volume: ${bid.volume}`);
        }
        
        console.log('Asks:');
        for (const ask of this.asks[this.tokenSymbol]) {
            console.log(`Price: ${ask.price}, Volume: ${ask.volume}`);
        }
        
        console.log('-------------------');

        return orderBook;
    }
}
  
module.exports = OrderBook;