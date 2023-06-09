// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./IOffering.sol";
import "./IConsolidatedAuditTrail.sol";

contract Offering is IOffering {

    IConsolidatedAuditTrail catContract;

    string[] jurisdictions;


    event UpdateDescription(address sender,string oldDescription,string newDescription);
    event ChangeRestrictedSecrity(address sender,bool value);
    event ChangeRule144Transfers(address sender,bool valule);

    constructor(address _owner, address _issuer, string memory _name,string memory _symbol, uint256 _tokens, address _catContractAddress, bool _exemptOffering) {
        name = _name;
        symbol = _symbol; // Maximum 11 characters
        decimals = 0;
        owner = _owner;
        // adjust the totalSupply to equal the quotient of the max offering of $20,000,000 and the share price (or par value, whichever is greater)
        _totalSupply = _tokens;
        // Give the issuer the total supply and authorize as a transfer agent
        issuer = _issuer;
        whitelisted[issuer] = INVESTOR_struct(issuer,true,string("all"),9);
        balances[issuer] = _totalSupply;
        transfer_agents[issuer] = true;
        _transfer_agents.push(issuer);

        catContract = IConsolidatedAuditTrail(_catContractAddress);

        jurisdictions.push(string("all"));

        EXEMPT_OFFERING = _exemptOffering;
    }

    function getMaxOffering() public view override returns(uint256) {
        return MAX_OFFERING;
    }

    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public isAuthorized returns (bool success) {
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
    function setMaxShares(uint256 value) override public isTransferAgent {
        uint256 oldMaxShares = MAX_OFFERING_SHARES;
        MAX_OFFERING_SHARES = value;
        emit UpdateMaxShares(msg.sender,MAX_OFFERING_SHARES,oldMaxShares);
    }
}