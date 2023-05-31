// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./IERC20TOKEN.sol";

abstract contract BaseOffering is IERC20TOKEN {
    uint256 public constant YEAR = 365 days;
    string public name;
    string public symbol;
    uint8  public decimals;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping(address => uint256) transfer_log;
    mapping(address => bool) whitelisted;
    mapping(address => bool) transfer_agents;

    mapping(address => uint256) requested_purchase;
    mapping(address => uint256) requested_selling;

    address[] accredited_investors;
    address[] nonaccredited_investors;
    address[] affiliate_investors;
    address[] broker_dealers;
    address[] _transfer_agents;

    event Disapproval(address indexed investor, uint tokens, string reason);
    event Request(address investor,uint tokens,bool buy);
    event UpdateCUSIP(address transferAgent, string newCUSIP, string oldCUSIP);
    event UpdateSECFileNumber(address transferAgent, string newSECFileNumber, string oldSECFileNumber);
    event UpdateMaxOffering(address transferAgent, uint256 newMaxOffering, uint256 oldMaxOffering);
    event UpdateMaxShares(address transferAgent, uint256 newShares,uint256 oldhares);

    modifier isAuthorized() {
        require(whitelisted[msg.sender],"not authorized");
        _;
    }

    modifier isTransferAgent() {
        require(transfer_agents[msg.sender],"not authorized transfer agent");
        _;
    } 

    function getOwner() public view returns(address) {
        return owner;
    }

    function addInvestor(address investor, uint investor_type)
        public isTransferAgent
    {
        require(whitelisted[investor] == false,"investor already exists");
        if (investor_type == 1) {
          accredited_investors.push(investor);
        } else if (investor_type == 2) {
          affiliate_investors.push(investor);
        } else if (investor_type == 3) {
          broker_dealers.push(investor);
        } else {
          nonaccredited_investors.push(investor);
        }
        whitelisted[investor] = true;
    }

    function addTransferAgent(address transferAgent) public
    {
        require(msg.sender == owner,"only for owner access");
        require(msg.sender != transferAgent,"contract owner cannot be the transfer agent");
        require(transfer_agents[transferAgent] == false,"transfer agent already exists");
        transfer_agents[transferAgent] = true;
        _transfer_agents.push(transferAgent);
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

    /**
     * @dev allowance : Check approved balance
     */
    function allowance(address tokenOwner, address spender) virtual override public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
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
        requested_purchase[msg.sender] = SafeMath.add(requested_purchase[msg.sender],tokens);
        emit Request(msg.sender,tokens,true);
        return true;
    }

    function resetBuy(address investor) public isTransferAgent {
        requested_purchase[investor] = 0;
    }

    function requestSell(uint tokens) public isAuthorized returns (bool success) {
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

    function setCUSIP(string memory cusip) virtual public;
    function setSECFilenumber(string memory fileNumber) virtual public;
    function setMaxOffering(uint256 value) virtual public;
    function setMaxShares(uint256 value) virtual public;

}
