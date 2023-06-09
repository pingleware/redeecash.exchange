// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./Offering.sol";

contract OfferingPool {
    struct Token {
        string name;
        string symbol;
        address contractAddress;
        string offeringType;
    }

    mapping(string => Token) public tokenContracts;
    mapping(address => bool) public isToken;
    Token[] public tokens;

    address owner;

    struct Order {
        address token;
        address trader;
        uint256 amount;
        uint256 price;
    }

    mapping(string => Order[]) public buyOrders;
    mapping(string => Order[]) public sellOrders;

    mapping(string => uint256) public highestBid;
    mapping(string => uint256) public lowestAsk;

    mapping(address => uint256) public traders;

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

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return traders[wallet];
    }


    function createToken(address _issuer, string memory _name, string memory _symbol, uint _tokens,address _catContractAddress,string memory _regulation,bool _exemptOffering) public isOwner {
        require(tokenContracts[_symbol].contractAddress == address(0), "Token already exists");

        address newToken = address(new Offering(owner,_issuer,_name,_symbol, _tokens, _catContractAddress,_exemptOffering));
        tokenContracts[_symbol] = Token(_name,_symbol,newToken,_regulation);
    }

    function addTransferAgent(string memory symbol,address transferAgent) public isOwner {
        require(tokenContracts[symbol].contractAddress != address(0x0),"token not found for symbol");
        IOffering token = IOffering(tokenContracts[symbol].contractAddress);
        token.addTransferAgent(transferAgent);
    }

    // Function to update the highest bid and lowest ask prices
    function updateQuoting(string calldata _currencyPair) internal {
        Order[] storage buys = buyOrders[_currencyPair];
        Order[] storage sells = sellOrders[_currencyPair];

        if (buys.length > 0) {
            highestBid[_currencyPair] = buys[buys.length - 1].price;
        } else {
            highestBid[_currencyPair] = 0;
        }

        if (sells.length > 0) {
            lowestAsk[_currencyPair] = sells[0].price;
        } else {
            lowestAsk[_currencyPair] = 0;
        }
    }

    // Function to match buy and sell orders
    function matchOrders(string calldata _currencyPair) internal {
        Order[] storage buys = buyOrders[_currencyPair];
        Order[] storage sells = sellOrders[_currencyPair];

        if (buys.length == 0 || sells.length == 0) {
            return;
        }

        uint256 i = 0;
        uint256 j = 0;

        while (i < buys.length && j < sells.length) {
            Order storage buyOrder = buys[i];
            Order storage sellOrder = sells[j];

            if (buyOrder.price >= sellOrder.price) {
                uint256 tradeAmount = (buyOrder.amount <= sellOrder.amount)
                    ? buyOrder.amount
                    : sellOrder.amount;
                uint256 tradePrice = sellOrder.price;

                emit TradeExecuted(
                    _currencyPair,
                    buyOrder.trader,
                    sellOrder.trader,
                    tradeAmount,
                    tradePrice
                );

                // transfer the tokens on the contract
                IOffering token = IOffering(tokenContracts[_currencyPair].contractAddress);
                token.updateTransferAllocation(token.getIssuer(),sellOrder.trader,tradeAmount);
                token.updateTransferAllocation(token.getIssuer(),buyOrder.trader,tradeAmount);
                token.transferFrom(sellOrder.trader,buyOrder.trader,tradeAmount);


                // Update order amounts and remove filled orders
                if (buyOrder.amount <= sellOrder.amount) {
                    sells[j].amount -= buyOrder.amount;
                    buys[i] = buys[buys.length - 1];
                    buys.pop();
                    i++;
                } else {
                    buys[i].amount -= sellOrder.amount;
                    sells[j] = sells[sells.length - 1];
                    sells.pop();
                    j++;
                }
            } else {
                break;
            }
        }
    }

    // Function to get quote
    function getQuote(string calldata _currencyPair)
        public
        view
        returns (uint256, uint256)
    {
        return (highestBid[_currencyPair],lowestAsk[_currencyPair]);
    }


    // Function to get the buy orders for a currency pair
    function getBuyOrders(string calldata _currencyPair)
        public
        view
        returns (Order[] memory)
    {
        return buyOrders[_currencyPair];
    }

    // Function to get the sell orders for a currency pair
    function getSellOrders(string calldata _currencyPair)
        public
        view
        returns (Order[] memory)
    {
        return sellOrders[_currencyPair];
    }

    // Function to place a buy order
    function placeBuyOrder(
        address _wallet,
        string calldata _currencyPair,
        uint256 _amount,
        uint256 _price
    ) public {
        require(_amount > 0, "Invalid amount");
        require(_price > 0, "Invalid price");
        require(tokenContracts[_currencyPair].contractAddress != address(0),"not a listed currency pair");

        IOffering token = IOffering(tokenContracts[_currencyPair].contractAddress);
        require(token.checkWhitelisted(),"not authorized to place buy order");

        Order memory order = Order(tokenContracts[_currencyPair].contractAddress,_wallet, _amount, _price);
        buyOrders[_currencyPair].push(order);

        emit BuyOrderPlaced(_currencyPair, _wallet, _amount, _price);

        updateQuoting(_currencyPair);
        matchOrders(_currencyPair);
    }

    // Function to place a sell order
    function placeSellOrder(
        address _wallet,
        string calldata _currencyPair,
        uint256 _amount,
        uint256 _price
    ) public {
        require(_amount > 0, "Invalid amount");
        require(_price > 0, "Invalid price");
        require(tokenContracts[_currencyPair].contractAddress != address(0),"not a listed currency pair");

        IOffering token = IOffering(tokenContracts[_currencyPair].contractAddress);
        require(token.checkTransferAgent(),"not authorized to place sell order");
        require(token.getBalanceFrom(_wallet) >= _amount,"insufficient balance in sellers account");

        Order memory order = Order(tokenContracts[_currencyPair].contractAddress,_wallet, _amount, _price);
        sellOrders[_currencyPair].push(order);

        emit SellOrderPlaced(_currencyPair, _wallet, _amount, _price);

        updateQuoting(_currencyPair);
        matchOrders(_currencyPair);
    }

}