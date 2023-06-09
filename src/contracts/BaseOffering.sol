// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./IERC20TOKEN.sol";

abstract contract BaseOffering is IERC20TOKEN {
    struct INVESTOR_struct {
        address wallet;
        bool active;
        string jurisdiction;
        uint level;
    }

    uint256 public constant YEAR = 365 days;
    uint256 public constant SIXMONTHS = 183 days;

    bool public RESTRICTED_SECURITY;
    bool public MANDATORY_REPORTING = false;

    int public MAX_NONACCREDITED_INVESTORS = -1;
    
    string public name;
    string public symbol;
    uint8  public decimals;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping(address => uint256) transfer_log;
    mapping(address => INVESTOR_struct) whitelisted;
    mapping(address => bool) transfer_agents;
    mapping(address => uint256) public allocation;
    mapping(address => uint256) public deallocation;
    mapping(address => uint256) public transfer_allocation;

    mapping(address => uint256) requested_purchase;
    mapping(address => uint256) requested_selling;

    address[] accredited_investors;
    address[] nonaccredited_investors;
    address[] affiliate_investors;
    address[] broker_dealers;
    address[] _transfer_agents;

    string[] jurisdictions;

    event CreatedNewOffering(address owner,address issuer,string name,string symbol,uint256 tokens,address catAddress,bool exemptOffering);
    event UpdateDescription(address sender,string oldDescription,string newDescription);
    event ChangeRestrictedSecrity(address sender,bool value);
    event ChangeRule144Transfers(address sender,bool valule);
    event Disapproval(address indexed investor, uint tokens, string reason);
    event Request(address investor,uint tokens,bool buy);
    event UpdateRestrictedSecurity(address sender,bool oldValue,bool newValue);
    event UpdateCUSIP(address transferAgent, string newCUSIP, string oldCUSIP);
    event UpdateSECFileNumber(address transferAgent, string newSECFileNumber, string oldSECFileNumber);
    event UpdateMaxOffering(address transferAgent, uint256 newMaxOffering, uint256 oldMaxOffering);
    event UpdateMaxShares(address transferAgent, uint256 newShares,uint256 oldhares);
    event AddedTransferAgent(address sender,address transferAgent);

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

    function findJurisdiction(string memory jurisdiction) public view returns(bool) {
        bool found = false;
        for (uint i=0; i<jurisdictions.length; i++) {
            if (keccak256(bytes(jurisdictions[i])) == keccak256(bytes(jurisdiction))) {
                found = true;
            }            
        }
        return found;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getIssuer() public view returns (address) {
        return issuer;
    }

    function addJurisdiction(string memory jurisdiction) external {
        bool found = findJurisdiction(jurisdiction);
        require(found == false,"jurisdiction has already been added");
        jurisdictions.push(jurisdiction);
    }


    function addInvestor(address investor, uint investor_type,string memory jurisdiction)
        public isTransferAgent
    {
        require(whitelisted[investor].active == false,"investor already exists");
        if (investor_type == 1) {
          accredited_investors.push(investor);
        } else if (investor_type == 2) {
          affiliate_investors.push(investor);
        } else if (investor_type == 3) {
          broker_dealers.push(investor);
        } else {
            if (MAX_NONACCREDITED_INVESTORS > 0) {
                int256 count = int256(nonaccredited_investors.length);
                if (count <= MAX_NONACCREDITED_INVESTORS) {
                    nonaccredited_investors.push(investor);
                }
            }
        }
        INVESTOR_struct memory _investor = INVESTOR_struct(msg.sender,true,jurisdiction,investor_type);
        whitelisted[investor] = _investor;
    }

    function addTransferAgent(address transferAgent) public isOwner
    {
        require(msg.sender == owner,"only for owner access");
        require(msg.sender != transferAgent,"contract owner cannot be the transfer agent");
        require(transfer_agents[transferAgent] == false,"transfer agent already exists");
        transfer_agents[transferAgent] = true;
        _transfer_agents.push(transferAgent);
        emit AddedTransferAgent(msg.sender, transferAgent);
    }

    function getTransferAgents() public view returns (address[] memory) {
        return _transfer_agents;
    }

    function getInvestors() public view isTransferAgent returns(address[] memory,address[] memory,address[] memory,address[] memory) 
    {
        return (nonaccredited_investors,accredited_investors,affiliate_investors,broker_dealers);
    }

    function getRequested(address investor,bool buy) public view isTransferAgent returns(uint256) {
        if (buy) {
            return requested_purchase[investor];
        }
        return requested_selling[investor];
    }

    function checkWhitelisted() public view override returns (bool) {
        return whitelisted[msg.sender].active;
    }

    function checkTransferAgent() public view override returns (bool) {
        return transfer_agents[msg.sender];
    }

    function getBalanceFrom(address wallet) public view override returns (uint256) {
        return balances[wallet];
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

    function requestBuy(uint tokens) public isAuthorized returns (bool success) {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authroized to buy, out of jurisdiction");
        requested_purchase[msg.sender] = SafeMath.add(requested_purchase[msg.sender],tokens);
        emit Request(msg.sender,tokens,true);
        return true;
    }

    function resetBuy(address investor) public isTransferAgent {
        requested_purchase[investor] = 0;
    }

    function requestSell(uint tokens) public isAuthorized returns (bool success) {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authroized to buy, out of jurisdiction");
        requested_selling[msg.sender] = SafeMath.add(requested_selling[msg.sender],tokens);
        emit Request(msg.sender,tokens,false);
        return true;
    }

    function resetSell(address investor) public isTransferAgent {
        requested_selling[investor] = 0;
    }

    /**
     * @dev totalSupply : Display total supply of token
     */ 
    function totalSupply() virtual override public view returns (uint) {
        return _totalSupply;
    }
    
    /**
     * @dev balanceOf : Displya token balance of given address
     */ 
    function balanceOf(address tokenOwner) virtual override public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function setRestrictedSecurity(bool value) external {
        bool oldValue = RESTRICTED_SECURITY;
        RESTRICTED_SECURITY = value;
        emit UpdateRestrictedSecurity(msg.sender, oldValue, value);
    }

    function setCUSIP(string memory cusip) virtual public;
    function setSECFilenumber(string memory fileNumber) virtual public;
    function setMaxOffering(uint256 value) virtual public;
    function setMaxShares(uint256 value) virtual public;


}