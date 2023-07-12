// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IBaseOffering.sol";

abstract contract BaseOffering is IBaseOffering {
    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    modifier isAuthorized() {
        require(whitelisted[msg.sender].active,"not authorized");
        _;
    }

    modifier isTransferAgent() {
        require(transfer_agents[msg.sender],"not authorized transfer agent");
        _;
    } 

    modifier isJurisdiction() {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authorized for the jurisdiction");
        _;
    }

    modifier isIssuer() {
        require(msg.sender == issuer,"not authorized for issuer");
        _;
    }

    modifier isParticipant() {
        require(poolContract.getInvestorStatus(msg.sender),"not a registered market participant. must register at https://redeecash.exchange to be a market participant by completing an applpication and an affidavit.");
        _;
    }

    function transferOwnership(address newOwner) override external isOwner {
        require(newOwner != address(0), "Invalid address");
        address previousOwner = owner;
        owner = newOwner;
        emit ChangedOwner(previousOwner,owner);
    }

    function isWhitelisted(address wallet) internal view returns (bool) {
        return whitelisted[wallet].active;
    }

    function findJurisdiction(string memory jurisdiction) internal view returns(bool) {
        bool found = false;
        for (uint i=0; i<jurisdictions.length; i++) {
            if (keccak256(bytes(jurisdictions[i])) == keccak256(bytes(jurisdiction))) {
                found = true;
            }            
        }
        return found;
    }

    function getOwner() override external view returns(address) {
        return owner;
    }

    function getIssuer() override external view returns (address) {
        return issuer;
    }

    function addJurisdiction(string memory jurisdiction) override external isTransferAgent {
        bool found = findJurisdiction(jurisdiction);
        require(found == false,"jurisdiction has already been added");
        jurisdictions.push(jurisdiction);
    }


    function addInvestor(address investor) override external isTransferAgent
    {
        require(whitelisted[investor].active == false,"investor already exists");
        require(poolContract.isWhitelisted(investor),"investor is not authorized");
        require(findJurisdiction(poolContract.getInvestorJurisdiction(investor)),"investor does not reside in authorized jurisdiction");
        whitelisted[investor] = INVESTOR(investor,true,poolContract.getInvestorJurisdiction(investor),poolContract.getInvestorLevel(investor));
        emit AddedInvestor(investor,poolContract.getInvestorJurisdiction(investor),poolContract.getInvestorLevel(investor));
    }

    function addTransferAgent(address transferAgent) override external isOwner
    {
        require(msg.sender == owner,"only for owner access");
        require(msg.sender != transferAgent,"contract owner cannot be the transfer agent");
        require(transfer_agents[transferAgent] == false,"transfer agent already exists");
        transfer_agents[transferAgent] = true;
        _transfer_agents.push(transferAgent);
        emit AddedTransferAgent(msg.sender, transferAgent);
    }

    function getTransferAgents() override external view returns (address[] memory) {
        return _transfer_agents;
    }

    function getInvestors() override external view isTransferAgent returns(address[] memory) 
    {
        return (new_requests);
    }

    function getRequested(address investor,bool buy) override external view isTransferAgent returns(uint256) {
        if (buy) {
            return requested_purchase[investor];
        }
        return requested_selling[investor];
    }

    function checkWhitelisted() public view override returns (bool) {
        return whitelisted[msg.sender].active;
    }

    function checkTransferAgent() external view override returns (bool) {
        return transfer_agents[msg.sender];
    }

    function getBalanceFrom(address wallet) public view override returns (uint256) {
        return balances[wallet];
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

    /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender) virtual override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function updateTransferAllocation(address _issuer, address wallet,uint256 amount) public override isTransferAgent {
        require(_issuer == issuer,"not authorized issuer");
        require(whitelisted[wallet].active,"trader is not whitelisted");
        transfer_allocation[wallet] = amount;
    }

    
    /**
     * @dev approve : Approve token for spender
     */ 
    function approve(address spender, uint tokens) virtual override public isTransferAgent returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function approveTransaction(address from, address to, uint tokens) public isTransferAgent returns (bool success) {
        require(tokens >= 0, "Invalid value");
        allowed[from][to] = tokens;
        emit Approval(from, to, tokens);
        return true;
    }

    function disapprove(address investor,bool buy,string memory reason) public isTransferAgent {
        uint tokens = 0;
        if (buy) {
            tokens = requested_purchase[investor]; 
            requested_purchase[investor] = 0;
            delete requested_purchase[investor];
        } else {
            tokens = requested_selling[investor];
            requested_selling[investor] = 0;
            delete requested_selling[investor];
        }
        emit Disapproval(investor,tokens,reason);
    }

    function requestBuy(uint tokens) override external isAuthorized returns (bool success) {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authroized to buy, out of jurisdiction");
        requested_purchase[msg.sender] = SafeMath.add(requested_purchase[msg.sender],tokens);
        emit Request(msg.sender,tokens,true);
        return true;
    }

    function resetBuy(address investor) override external isTransferAgent {
        requested_purchase[investor] = 0;
    }

    function requestSell(uint tokens) override external isAuthorized returns (bool success) {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authroized to buy, out of jurisdiction");
        requested_selling[msg.sender] = SafeMath.add(requested_selling[msg.sender],tokens);
        emit Request(msg.sender,tokens,false);
        return true;
    }

    function resetSell(address investor) override external isTransferAgent {
        requested_selling[investor] = 0;
    }

    /**
     * @dev totalSupply : Display total supply of token
     */ 
    function totalSupply() virtual override public view returns (uint) {
        return _totalSupply;
    }
    
    /**
     * @dev balanceOf : Display token balance of given address
     */ 
    function balanceOf(address tokenOwner) virtual override public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function setRestrictedSecurity(bool value) override external isTransferAgent {
        bool oldValue = RESTRICTED_SECURITY;
        RESTRICTED_SECURITY = value;
        emit UpdateRestrictedSecurity(msg.sender, oldValue, value);
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

    function getContractBalance() override external view returns (uint256) {
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