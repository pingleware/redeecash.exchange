// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IOffering.sol";
import "./IConsolidatedAuditTrail.sol";

contract Offering is IOffering {

    IConsolidatedAuditTrail catContract;

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

    bool public TRADING_ACTIVE=true;
    bool public TRANSFERS_ACTIVE=true;
    bool public MINTING_ACTIVE=true;
    bool public BURNING_ACTIVE=true;

    event ValueTransferred(address sender, uint256 amount);
    event TradingSuspended(string reason);
    event TradingResumed(string reason);

    event TransfersSuspended(string reason);
    event TransfersResumed(string reason);

    event MintingSuspended(string reason);
    event MintingResume(string reason);

    event BurningSuspended(string reason);
    event BurningResume(string reason);

    constructor(address _owner, address _issuer, string memory _name,string memory _symbol, uint256 _tokens, uint256 _price, address _catContractAddress, bool _exemptOffering) {
        name = _name;
        symbol = _symbol; // Maximum 11 characters
        decimals = 0;
        owner = _owner;
        // adjust the totalSupply to equal the quotient of the max offering of $20,000,000 and the share price (or par value, whichever is greater)
        _totalSupply = _tokens;
        MAX_OFFERING_SHARES = _tokens;
        // Give the issuer the total supply and authorize as a transfer agent
        issuer = _issuer;
        whitelisted[issuer] = INVESTOR_struct(issuer,true,string("all"),9);
        balances[issuer] = _totalSupply;
        transfer_agents[issuer] = true;
        _transfer_agents.push(issuer);
        price =  _price;

        catContract = IConsolidatedAuditTrail(_catContractAddress);

        jurisdictions.push(string("all"));

        EXEMPT_OFFERING = _exemptOffering;

        emit CreatedNewOffering(_owner, _issuer, _name, _symbol, _tokens, _price, _catContractAddress, _exemptOffering);
    }

    // Function to receive Ether and transfer it to the contract's balance
    receive() external payable {
        // Emitting the event to log the transfer
        emit ValueTransferred(msg.sender, msg.value);
    }


    function getMaxOffering() public view override returns(uint256) {
        return MAX_OFFERING;
    }

    function changeTradingStatus(bool status, string calldata reason) external isOwner {
        TRADING_ACTIVE = status;
        if (status) {
            emit TradingResumed(reason);
        } else {
            emit TradingSuspended(reason);
        }
    }
    function changeTransferStatus(bool status, string calldata reason) external isOwner {
        TRANSFERS_ACTIVE = status;
        if (status) {
            emit TransfersResumed(reason);
        } else {
            emit TransfersSuspended(reason);
        }
    }
    function changeMintingStatus(bool status, string calldata reason) external isOwner {
        MINTING_ACTIVE = status;
        if (status) {
            emit MintingResume(reason);
        } else {
            emit MintingSuspended(reason);
        }
    }
    function changeBurningStatus(bool status, string calldata reason) external isOwner {
        BURNING_ACTIVE = status;
        if (status) {
            emit BurningResume(reason);
        } else {
            emit BurningSuspended(reason);
        }
    }


    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public isAuthorized returns (bool success) {
        require(TRANSFERS_ACTIVE,"transfers have been suspended");
        require(to != address(0), "Null address");  
        if (EXEMPT_OFFERING) {
            require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authorized to send, out of jurisdiction");
            require(findJurisdiction(whitelisted[to].jurisdiction),"not authorized to receive, out of jurisdiction");
        }
        require(whitelisted[to].active,"recipient is not authorized to receive tokens");                                       
        require(tokens > 0, "Invalid Value");
        if (RULE144_TRANSFERS && msg.sender != issuer) {
            require (block.timestamp >= (transfer_log[msg.sender] + YEAR),"transfer not permitted under Rule 144, holding period has not elapsed");
        }
        transfer_log[to] = block.timestamp;
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        if (transfer_agents[msg.sender]) {
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
        }
        emit Transfer(msg.sender, to, tokens);
        // save CAT
        IConsolidatedAuditTrail.Transaction memory transaction = IConsolidatedAuditTrail.Transaction(msg.sender,to,tokens);
        catContract.addAuditTrail(owner,symbol,transaction,block.timestamp);
        return true;
    }
    
    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) virtual override public isAuthorized returns (bool success) {
        require(TRANSFERS_ACTIVE,"transfers have been suspended");
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        if (EXEMPT_OFFERING) {
            require(findJurisdiction(whitelisted[from].jurisdiction),"not authorized to send, out of jurisdiction");
            require(findJurisdiction(whitelisted[to].jurisdiction),"not authorized to receive, out of jurisdiction");
        }
        require(whitelisted[to].active,"recipient is not authorized to receive tokens");
        require(tokens > 0, "Invalid value"); 
        if (RULE144_TRANSFERS && from != issuer) {
            require (block.timestamp >= (transfer_log[from] + YEAR),"transfer not permitted under Rule 144, holding period has not elapsed");
        }
        require(tokens <= balances[from], "Insufficient balance");
        require(tokens <= allowed[from][to], "Insufficient allowance");
        transfer_log[to] = block.timestamp;
        balances[from] = SafeMath.safeSub(balances[from], tokens);
        allowed[from][to] = SafeMath.safeSub(allowed[from][to], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        if (transfer_agents[from]) {
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
        }
        emit Transfer(from, to, tokens);

        // save CAT
        IConsolidatedAuditTrail.Transaction memory transaction = IConsolidatedAuditTrail.Transaction(from,to,tokens);
        catContract.addAuditTrail(owner,symbol,transaction,block.timestamp);

        return true;
    }



    /**
     * @dev mint : To increase total supply of tokens
     */ 
    function mint(uint256 _amount) public override returns (bool) {
        require(MINTING_ACTIVE,"minting has been suspended");
        require(_amount >= 0, "Invalid amount");
        require(issuer == msg.sender, "not authorized, only the issuer can mint more tokens");
        require(_totalSupply < MAX_OFFERING_SHARES,"maximum offering has been reached, minting is disabled");
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
        balances[msg.sender] = SafeMath.safeAdd(balances[msg.sender], _amount);
        emit Transfer(address(0), msg.sender, _amount);

        // save CAT
        IConsolidatedAuditTrail.Transaction memory transaction = IConsolidatedAuditTrail.Transaction(address(0),msg.sender,_amount);
        catContract.addAuditTrail(owner,symbol,transaction,block.timestamp);
        return true;
    }
    
     /**
     * @dev mint : To increase total supply of tokens
     */ 
    function burn(uint256 _amount) public override returns (bool) {
        require(BURNING_ACTIVE,"burning has been suspended");
        require(_amount >= 0, "Invalid amount");
        require(issuer == msg.sender, "not authorized, only the issuer can burn more tokens");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        require(_totalSupply > 0,"no remaining tokens to burn");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _amount);
        emit Transfer(msg.sender, address(0), _amount);

        // save CAT
        IConsolidatedAuditTrail.Transaction memory transaction = IConsolidatedAuditTrail.Transaction(msg.sender,address(0),_amount);
        catContract.addAuditTrail(owner,symbol,transaction,block.timestamp);
        return true;
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
                    symbol,
                    buyOrder.wallet,
                    sellOrder.wallet,
                    tradeAmount,
                    tradePrice
                );

                // transfer the tokens on the contract
                updateTransferAllocation(issuer,sellOrder.wallet,tradeAmount);
                updateTransferAllocation(issuer,buyOrder.wallet,tradeAmount);
                transferFrom(sellOrder.wallet,buyOrder.wallet,tradeAmount);


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
        require(TRADING_ACTIVE,"trading has been suspended");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(msg.value > SafeMath.safeMul(quantity, price),"insufficient funds to place buy order");
        require(OUTSTANDING_SHARES == _totalSupply,"trading disabled until initial offering has been completed");

        // Storing the buy order details
        Order memory order = Order(nextOrderId, msg.sender, quantity, price, msg.value);
        buyOrders[nextOrderId] = order;
        nextOrderId++;

        emit BuyOrderPlaced(symbol, msg.sender, quantity, price);

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
        require(TRADING_ACTIVE,"trading has been suspended");
        require(quantity > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(OUTSTANDING_SHARES == _totalSupply,"trading disabled until initial offering has been completed");
        require(getBalanceFrom(msg.sender) >= quantity,"insufficient balance in sellers account");

        Order memory order = Order(nextOrderId, msg.sender, quantity, price, 0);
        sellOrders[nextOrderId] = order;
        nextOrderId++;

        emit SellOrderPlaced(symbol, msg.sender, quantity, price);

        updateQuoting();
        matchOrders();
    }
    // Cancel pending sell order
    function cancelSell(uint256 orderId) external {
        Order storage order = sellOrders[orderId];
        require(order.wallet == msg.sender, "You are not the owner of this order.");
        delete sellOrders[orderId];
    }
    function getOrders() external view returns(Order[] memory,Order[] memory) {
        return(buyOrders,sellOrders);
    }

    function setDESCRIPTION(string memory description) public isTransferAgent {
        string memory oldDescription = DESCRIPTION;
        DESCRIPTION = description;
        emit UpdateDescription(msg.sender, oldDescription, DESCRIPTION);
    }
    function setRESTRICTED(bool value) public isTransferAgent {
        RESTRICTED_SECURITY = value;
        emit ChangeRestrictedSecrity(msg.sender, value);
    }
    function setRULE144TRANSFERS(bool value) public isTransferAgent {
        RULE144_TRANSFERS = value;
        emit ChangeRule144Transfers(msg.sender, value);
    }

    function setCUSIP(string memory cusip) override public isTransferAgent {
        string memory oldCUSIP = CUSIP;
        CUSIP = cusip;
        emit UpdateCUSIP(msg.sender,CUSIP,oldCUSIP);
    }
    function setSECFilenumber(string memory fileNumber) override public isTransferAgent {
        string memory oldSECFileNumber = SEC_FILENUMBER;
        SEC_FILENUMBER = fileNumber;
        emit UpdateSECFileNumber(msg.sender,SEC_FILENUMBER,oldSECFileNumber);
    }
    function setMaxOffering(uint256 value) override public isTransferAgent {
        uint256 oldMaxOffering = MAX_OFFERING;
        MAX_OFFERING = value;
        emit UpdateMaxOffering(msg.sender,MAX_OFFERING,oldMaxOffering);
    }
    function setMaxShares(uint256 value) override external isTransferAgent {
        uint256 oldMaxShares = MAX_OFFERING_SHARES;
        MAX_OFFERING_SHARES = value;
        emit UpdateMaxShares(msg.sender,MAX_OFFERING_SHARES,oldMaxShares);
    }
}