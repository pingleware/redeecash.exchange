// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IOffering.sol";
import "./IConsolidatedAuditTrail.sol";

contract Offering is IOffering {
    IConsolidatedAuditTrail catContract;
    mapping (address => uint256) buyRequests;

    event ValueTransferred(address sender, uint256 amount);

    constructor(address _owner, address _issuer, string memory _name,string memory _symbol, uint256 _tokens, uint256 _price, address _catContractAddress, bool _exemptOffering,address _poolContract) {
        name = _name;
        symbol = _symbol; // Maximum 11 characters
        decimals = 0;
        owner = _owner;
        // adjust the totalSupply to equal the quotient of the max offering of $20,000,000 and the share price (or par value, whichever is greater)
        _totalSupply = _tokens;
        MAX_OFFERING_SHARES = _tokens;
        // Give the issuer the total supply and authorize as a transfer agent
        issuer = _issuer;
        whitelisted[issuer] = INVESTOR(issuer,true,string("all"),9);
        balances[issuer] = _totalSupply;
        transfer_agents[issuer] = true;
        _transfer_agents.push(issuer);
        price =  _price;

        catContract = IConsolidatedAuditTrail(_catContractAddress);
        poolContract = IOfferingPool(_poolContract);

        jurisdictions.push(string("all"));

        EXEMPT_OFFERING = _exemptOffering;

        emit CreatedNewOffering(_owner, _issuer, _name, _symbol, _tokens, _price, _catContractAddress, _exemptOffering);
    }

    // Function to receive Ether and transfer it to the contract's balance
    receive() external payable {
        // Emitting the event to log the transfer
        emit ValueTransferred(msg.sender, msg.value);
    }

    function isFirstYearSecondaryTradingRestricted(uint256 usdAmount) view internal {
        if (SECONDARY_SALES_FIRST_YEAR_RESTRICTION) {
            if (block.timestamp > transfer_log[msg.sender] + YEAR) {
                uint256 threshold = (price * AGGREGATE_OFFERING_PRICE_PERCENT) / 100; // Calculate 30% of the original price
                require(usdAmount <= threshold,"new offering price exceeds 30% of token price in the first year of secondary trading");
            }
        }
    }

    function requestToBuy(uint256 value) override external isParticipant {
        require(value > 0, "requested amount must be greater than zero");
        request_to_buy[msg.sender] = request_to_buy[msg.sender] + value;
        new_requests.push(msg.sender);
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        payable(address(this)).transfer(msg.value); // msg.value in Wei
        emit Deposited(msg.sender,msg.value);
    }


    function withdraw(address recipient, uint256 amount) external payable isOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(recipient).transfer(amount);  // amount in Wei, e.g. catContract.usdToWei(500) = 267809319764327798 = amount
        emit Withdrawn(recipient,amount);
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) external isOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function getMaxOffering() public view override returns(uint256) {
        return MAX_OFFERING;
    }

    function getTradingStatus() override external view returns (bool) {
        return TRADING_ACTIVE;
    }
    function getTransferStatus() override external view returns (bool) {
        return TRANSFERS_ACTIVE;
    } 
    function getMintingStatus() override external view returns (bool) {
        return MINTING_ACTIVE;
    }
    function getBuringStatus() override external view returns (bool) {
        return BURNING_ACTIVE;
    }

    function changeTradingStatus(bool status, string calldata reason) override external isOwner {
        TRADING_ACTIVE = status;
        if (status) {
            emit TradingResumed(reason);
        } else {
            emit TradingSuspended(reason);
        }
    }
    function changeTransferStatus(bool status, string calldata reason) override external isOwner {
        TRANSFERS_ACTIVE = status;
        if (status) {
            emit TransfersResumed(reason);
        } else {
            emit TransfersSuspended(reason);
        }
    }
    function changeMintingStatus(bool status, string calldata reason) override external isOwner {
        MINTING_ACTIVE = status;
        if (status) {
            emit MintingResume(reason);
        } else {
            emit MintingSuspended(reason);
        }
    }
    function changeBurningStatus(bool status, string calldata reason) override external isOwner {
        BURNING_ACTIVE = status;
        if (status) {
            emit BurningResume(reason);
        } else {
            emit BurningSuspended(reason);
        }
    }

    /**
     * 1. An investor makes an on-chain purchase requqest using investorBuyRequest, which transfers the investors monies to the contract balance
     * 2. The transfer agent, approves the allowed amount
     * 3. The issuer will transfer the allowed tokens to the investor as well as transfer from the contract balance to the issuer wallet
     *
     * The investor can still purchase additional tokens offchain, and the issuer will transfer tokens using the transfer function.
     */
    function transferOnChainPurchase(address to, uint tokens) external isIssuer {
        uint256 usdAmount = SafeMath.safeMul(price,tokens);
        uint256 ethAmount = catContract.usdToWei(usdAmount);
        require (address(this).balance > ethAmount,"insufficient contract balance");

        payable(address(issuer)).transfer(ethAmount);
        transfer(to,tokens);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
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
        allowed[msg.sender][to] = SafeMath.safeSub(allowed[msg.sender][to], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        if (transfer_agents[msg.sender]) {
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
        }
        emit Transfer(msg.sender, to, tokens);
        // save CAT
        string memory eventData = ""; //msg.sender.concat(string(" transferred ").concat(tokens.concat(string(" to ").concat(to))));
        catContract.addAuditEntry(symbol,timestampToString(),"Transfer Token",eventData);
        return true;
    }

    function timestampToString() internal view returns (string memory) {
        uint256 timestamp = block.timestamp;
        uint256 maxLength = 20; // Maximum length of the string (adjust as needed)
        bytes memory buffer = new bytes(maxLength);
        uint256 i = maxLength - 1;
        
        while (timestamp > 0) {
            buffer[i--] = bytes1(uint8(48 + timestamp % 10)); // Convert digit to ASCII
            timestamp /= 10;
        }
        
        bytes memory result = new bytes(maxLength - i - 1);
        for (uint256 j = i + 1; j < maxLength; j++) {
            result[j - i - 1] = buffer[j];
        }
        
        return string(result);
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
        string memory eventData = ""; //from.toSlice() + string(" transferred ") + tokens.toSlice() + string(" to ") + to.toSlice();
        catContract.addAuditEntry(symbol,timestampToString(),"Transfer Token",eventData);

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
        string memory eventData = ""; //msg.sender.toSlice() + string(" minted(created) ") + _amount.toSlice() + string(" tokens ");
        catContract.addAuditEntry(symbol,timestampToString(),"Transfer Token",eventData);

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
        string memory eventData = ""; //msg.sender.toSlice() + string(" burned(removed) ") + _amount.toSlice() + string(" tokens ");
        catContract.addAuditEntry(symbol,timestampToString(),"Transfer Token",eventData);

        return true;
    }

    function investorBuyRequest(uint256 tokens) external payable isAuthorized {
        uint256 usdAmount = catContract.weiToUSD(msg.value) + 1;
        isFirstYearSecondaryTradingRestricted(usdAmount);
        require(usdAmount >= SafeMath.safeMul(price,tokens),"insufficient monies to buy");
        buyRequests[msg.sender] = SafeMath.safeAdd(buyRequests[msg.sender],tokens);
    }
    function getInvestorBuyRequest(address wallet) external view isTransferAgent returns (uint256) {
        return buyRequests[wallet];
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
    function setAggregateOfferingPricePercentage(uint256 percentage) override external isTransferAgent {
        uint256 oldAggregateOfferingPrice = AGGREGATE_OFFERING_PRICE_PERCENT;
        AGGREGATE_OFFERING_PRICE_PERCENT = percentage;
        emit AggregateOfferingPriceChange(msg.sender,oldAggregateOfferingPrice,percentage);
    }
    function setFirstYearSecondarySalesLimitation(bool status,string memory reason) override external isTransferAgent {
        SECONDARY_SALES_FIRST_YEAR_RESTRICTION = status;
        emit OverrideFirstYearSecondarySalesLimitation(msg.sender,status,reason);
    }

}