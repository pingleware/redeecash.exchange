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
    static async createTokenListing(poolContractAddress,tokenAddress,issuer,secFileNumber,name,symbol,tokens,price,ownerId) {
        const {
            poolABI,
            tokenABI
        } = require('./abi');

        try {
            const contract = new web3.eth.Contract(JSON.parse(poolABI), poolContractAddress);
            await contract.methods.assignToken(tokenAddress,issuer,name,symbol,tokens,price).call({from: ownerId});
            const tokenContract = new web3.eth.Contract(JSON.parse(tokenABI), tokenAddress);
            return tokenContract;    
        } catch(error) {
            console.error(error);
        }
    }
    
    // Add a buy order to the order book
    addBid(order) {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            const tokenAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, tokenAddress);

            await contract.methods.requestBuy({tokens: order.volume, from: order.userId }).call({from: order.userId.wallet});

            this.bids[this.tokenSymbol].push(order);
            this.sortBidsByPriceDesc();    
        });
      }
    
    // Add a sell order to the order book
    addAsk(order) {
        mongoose.collection('Token').find({symbol: this.tokenSymbol},async function(err, token){
            const tokenAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, tokenAddress);

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
            const tokenAddress = token[0].contractAddress;
            const abi = token[0].abi;
            const contract = new web3.eth.Contract(abi, tokenAddress);

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
                const tokenAddress = token[0].contractAddress;
                const abi = token[0].abi;
                const contract = new web3.eth.Contract(abi, tokenAddress);
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