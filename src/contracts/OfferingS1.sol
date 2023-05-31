// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * S-1 Offering:
 * Corporate Finance Reporting Manual at https://www.sec.gov/page/corpfin-section-landing
 *
 * Useful for an issuer who wishes to conduct a Direct Public Offering or DPO on the blockchain after their S-1 has been quallified.
 * The filing fee for an S-1 is at https://www.sec.gov/ofm/Article/feeamt.html
 * Currently is $92.70 per $1,000,000
 * If you have a PAR value of $5 per share, then the minimum authorized shares would be 200,000 shares.
 * Liquidity is most important in a public offering!
 */

import "./IOfferingS1.sol";

contract OfferingS1 is IOfferingS1 {

    constructor(address _owner, string memory _name,string memory _symbol, uint256 tokens) {
        name = _name;
        symbol = _symbol; // Maximum 11 characters
        decimals = 0;
        owner = _owner;
        whitelisted[owner] = true;
        // adjust the totalSupply to equal the quotient of the max offering of $20,000,000 and the share price (or par value, whichever is greater)
        _totalSupply = tokens;
        balances[owner] = _totalSupply;
    }

    function getMaxOffering() public view override returns(uint256) {
        return MAX_OFFERING;
    }

    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address to, uint tokens) virtual override public isTransferAgent returns (bool success) {
        require(to != address(0), "Null address");  
        require(whitelisted[to],"recipient is not authorized to receive tokens");                                       
        require(tokens > 0, "Invalid Value");
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) virtual override public isTransferAgent returns (bool success) {
        require(to != address(0), "Null address");
        require(from != address(0), "Null address");
        require(whitelisted[to],"recipient is not authorized to receive tokens");
        require(tokens > 0, "Invalid value"); 
        require(tokens <= balances[from], "insufficient balance for sender");
        require(tokens <= allowed[from][to], "insufficient allowance for receiver");
        balances[from] = SafeMath.safeSub(balances[from], tokens);
        allowed[from][to] = SafeMath.safeSub(allowed[from][to], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        transfer_log[to] = block.timestamp;
        emit Transfer(from, to, tokens);
        return true;
    }
    
    
    /**
     * @dev mint : To increase total supply of tokens
     */ 
    function mint(uint256 _amount) public override returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(owner == msg.sender, "not authorized, only the owner can mint more tokens");
        require(_totalSupply < MAX_OFFERING_SHARES,"maximum offering has been reached, minting is disabled");
        _totalSupply = SafeMath.safeAdd(_totalSupply, _amount);
        balances[owner] = SafeMath.safeAdd(balances[owner], _amount);
        emit Transfer(address(0), owner, _amount);
        return true;
    }
    
     /**
     * @dev mint : To increase total supply of tokens
     */ 
    function burn(uint256 _amount) public override returns (bool) {
        require(_amount >= 0, "Invalid amount");
        require(owner == msg.sender, "not authorized, only the owner can burn more tokens");
        require(_amount <= balances[msg.sender], "Insufficient Balance");
        require(_totalSupply > 0,"no remaining tokens to burn");
        _totalSupply = SafeMath.safeSub(_totalSupply, _amount);
        balances[owner] = SafeMath.safeSub(balances[owner], _amount);
        emit Transfer(owner, address(0), _amount);
        return true;
    }

    function setCUSIP(string memory cusip) override public isTransferAgent {
        CUSIP = cusip;
    }
    function setSECFilenumber(string memory fileNumber) override public isTransferAgent {
        SEC_FILENUMBER = fileNumber;
    }
    function setMaxOffering(uint256 value) override public isTransferAgent {
        MAX_OFFERING = value;
    }
    function setMaxShares(uint256 value) override public isTransferAgent {
        MAX_OFFERING_SHARES = value;
    }

}