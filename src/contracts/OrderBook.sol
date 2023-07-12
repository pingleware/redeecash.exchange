// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IBaseOffering.sol";
import "./IConsolidatedAuditTrail.sol";

contract OrderBook {
    address _owner;
    IConsolidatedAuditTrail catContract;
    IBaseOffering offering;


    struct Order {
        uint256 orderId;
        address wallet;
        uint256 quantity;
        uint256 price;
        uint256 paid;
    }


    Order[] public buyOrders;
    Order[] public sellOrders;

    uint256 public nextOrderId = 1;

    uint256 public highestBid;
    uint256 public lowestAsk;

    struct Trade {
        address buyer;
        address seller;
        address token;
        uint amount;
        bool isCompleted;
    }

    // Event emitted when a new buy order is placed
    event BuyOrderPlaced(
        string indexed currencyPair,
        address indexed trader,
        uint256 amount,
        uint256 price
    );

    // Event emitted when a new sell order is placed
    event SellOrderPlaced(
        string indexed currencyPair,
        address indexed trader,
        uint256 amount,
        uint256 price
    );

    // Event emitted when a trade is executed
    event TradeExecuted(
        string indexed currencyPair,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 price
    );

    event ValueTransferred(address sender, uint256 amount);


    constructor(address owner, address offeringContractAddress, address catContractAddress) {
        _owner = owner;
        catContract = IConsolidatedAuditTrail(catContractAddress);
        offering = IBaseOffering(offeringContractAddress);

    }

    function getOrders() external view returns(Order[] memory,Order[] memory) {
        return(buyOrders,sellOrders);
    }
        // Function to update the highest bid and lowest ask prices
    function updateQuoting() internal {    
        uint256 i = 0;
        uint256 j = 0;

        highestBid = buyOrders[0].price;
        for (i=1; i<buyOrders.length; i++) {
            if (buyOrders[i].price > highestBid) {
                highestBid = buyOrders[i].price;
            }
        }

        lowestAsk = sellOrders[0].price;
        for(j=1;j<sellOrders.length;j++) {
            if (sellOrders[j].price < lowestAsk) {
                lowestAsk = sellOrders[j].price;
            }
        }
    }
    // Function to match buy and sell orders
    function matchOrders() internal {
        if (buyOrders.length == 0 || sellOrders.length == 0) {
            return;
        }

        uint256 i = 0;
        uint256 j = 0;

        while (i < buyOrders.length && j < sellOrders.length) {
            Order memory buyOrder = buyOrders[i];
            Order memory sellOrder = sellOrders[j];

            if (buyOrder.price >= sellOrder.price) {
                uint256 tradeAmount = (buyOrder.quantity <= sellOrder.quantity)
                    ? buyOrder.quantity
                    : sellOrder.quantity;
                uint256 tradePrice = sellOrder.price;

                emit TradeExecuted(
                    offering.symbol(),
                    buyOrder.wallet,
                    sellOrder.wallet,
                    tradeAmount,
                    tradePrice
                );

                // transfer the tokens on the contract
                offering.updateTransferAllocation(offering.issuer(),sellOrder.wallet,tradeAmount);
                offering.updateTransferAllocation(offering.issuer(),buyOrder.wallet,tradeAmount);
                offering.transferFrom(sellOrder.wallet,buyOrder.wallet,tradeAmount);


                // Update order amounts and remove filled orders
                if (buyOrder.quantity <= sellOrder.quantity) {
                    sellOrders[j].quantity -= buyOrder.quantity;
                    delete buyOrders[i];
                    i++;
                } else {
                    buyOrders[i].quantity -= sellOrder.quantity;
                    delete sellOrders[j];
                    j++;
                }
            } else {
                break;
            }
        }
    }
    // Function to get quote
    function quote()
        external
        view
        returns (uint256, uint256)
    {
        return (highestBid,lowestAsk);
    }
    // Function to place a buy order
    function buy(
        uint256 quantity,
        uint256 price
    ) external payable {
        require(offering.getTradingStatus(),"trading has been suspended");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(msg.value > SafeMath.safeMul(quantity, price),"insufficient funds to place buy order");
        require(offering.OUTSTANDING_SHARES == offering._totalSupply,"trading disabled until initial offering has been completed");

        // Storing the buy order details
        Order memory order = Order(nextOrderId, msg.sender, quantity, price, msg.value);
        buyOrders[nextOrderId] = order;
        nextOrderId++;

        //emit BuyOrderPlaced(symbol, msg.sender, quantity, price);

        updateQuoting();
        matchOrders();
    }
    // Function to cancel and transfer contract balance to the caller, and remove the buy order
    function cancelBuy(uint256 orderId) external {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract has no balance.");

        Order storage order = buyOrders[orderId];
        require(order.wallet == msg.sender, "You are not the owner of this order.");

        uint256 refund = order.paid;

        delete buyOrders[orderId];

        payable(msg.sender).transfer(refund);
        emit ValueTransferred(msg.sender, refund);
    }
    // Function to place a sell order
    function sell(
        uint256 quantity,
        uint256 price
    ) external {
        require(offering.getTradingStatus(),"trading has been suspended");
        require(quantity > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(offering.OUTSTANDING_SHARES == offering._totalSupply,"trading disabled until initial offering has been completed");
        require(offering.getBalanceFrom(msg.sender) >= quantity,"insufficient balance in sellers account");

        Order memory order = Order(nextOrderId, msg.sender, quantity, price, 0);
        sellOrders[nextOrderId] = order;
        nextOrderId++;

        //emit SellOrderPlaced(symbol, msg.sender, quantity, price);

        updateQuoting();
        matchOrders();
    }
    // Cancel pending sell order
    function cancelSell(uint256 orderId) external {
        Order storage order = sellOrders[orderId];
        require(order.wallet == msg.sender, "You are not the owner of this order.");
        delete sellOrders[orderId];
    }

}