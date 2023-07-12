// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./IERC20TOKEN.sol";
import "./IOfferingPool.sol";
import "./IConsolidatedAuditTrail.sol";

abstract contract IBaseOffering is IERC20TOKEN {
    struct INVESTOR {
        address wallet;
        bool active;
        string jurisdiction;
        uint level;
    }

    IOfferingPool public poolContract;
    IConsolidatedAuditTrail public catContract;

    string public DESCRIPTION = string("TO BE DEFINED");
    bool public EXEMPT_OFFERING = false;
    bool public RULE144_TRANSFERS = false;
    uint256 public MAX_OFFERING_SHARES = 0; // based on the maximum allowance offering and intial share price
    uint256 public AGGREGATE_OFFERING_PRICE_PERCENT = 0; // used with SECONDARY_SALES_FIRST_YEAR_RESTRICTION and defines maximum price for
                                                // secondary sales in the first year
    bool public SECONDARY_SALES_FIRST_YEAR_RESTRICTION = false; // Reg A 230.251(a)(3)

    uint256 public OUTSTANDING_SHARES = 0;

    uint256 public constant YEAR = 365 days;
    uint256 public constant SIXMONTHS = 183 days;

    bool public RESTRICTED_SECURITY;
    bool public MANDATORY_REPORTING = false;

    int public MAX_NONACCREDITED_INVESTORS = -1;

    bool public TRADING_ACTIVE=true;
    bool public TRANSFERS_ACTIVE=true;
    bool public MINTING_ACTIVE=true;
    bool public BURNING_ACTIVE=true;

    string public name;
    string public symbol;
    uint8  public decimals;
    uint256 public price;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    mapping(address => uint256) transfer_log;
    mapping(address => INVESTOR) whitelisted;
    mapping(address => bool) transfer_agents;
    mapping(address => uint256) public allocation;
    mapping(address => uint256) public deallocation;
    mapping(address => uint256) public transfer_allocation;

    mapping(address => uint256) requested_purchase;
    mapping(address => uint256) requested_selling;

    mapping(address => uint256) public request_to_buy;

    address[] _transfer_agents;
    address[] new_requests;

    string[] public jurisdictions;

    event ChangedOwner(address owner,address newOwner);
    event CreatedNewOffering(address owner,address issuer,string name,string symbol,uint256 tokens,uint256 price,address catAddress,bool exemptOffering);
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
    event AddedInvestor(address investor,string jurisdiction,uint256 level);
    event TradingSuspended(string reason);
    event TradingResumed(string reason);
    event TransfersSuspended(string reason);
    event TransfersResumed(string reason);
    event MintingSuspended(string reason);
    event MintingResume(string reason);
    event BurningSuspended(string reason);
    event BurningResume(string reason);
    event Deposited(address,uint256);
    event Withdrawn(address,uint256);
    event AggregateOfferingPriceChange(address indexed sender, uint256 oldAmount,uint256 newAmount);
    event OverrideFirstYearSecondarySalesLimitation(address indexed sender,bool status,string reason);


    function transferOwnership(address newOwner) virtual external;
    function getOwner() virtual external view returns(address);
    function getIssuer() virtual external view returns (address);
    function addJurisdiction(string memory jurisdiction) virtual external;
    function addInvestor(address investor) virtual external;
    function addTransferAgent(address transferAgent) virtual external;
    function getTransferAgents() virtual external view returns (address[] memory);
    function getInvestors() virtual external view returns(address[] memory);
    function getRequested(address investor,bool buy) virtual external view returns(uint256);

    function requestBuy(uint tokens) virtual external returns (bool success);
    function resetBuy(address investor) virtual external;
    function requestSell(uint tokens) virtual external returns (bool success);
    function resetSell(address investor) virtual external;

    function setRestrictedSecurity(bool value) virtual external;

    function setCUSIP(string memory cusip) virtual external;
    function setSECFilenumber(string memory fileNumber) virtual external;
    function setMaxOffering(uint256 value) virtual external;
    function setMaxShares(uint256 value) virtual external;

    function getTradingStatus() virtual external view returns (bool);
    function getTransferStatus() virtual external view returns (bool);
    function getMintingStatus() virtual external view returns (bool);
    function getBuringStatus() virtual external view returns (bool);

    function getContractBalance() virtual external view returns (uint256);

    function mint(uint256 _amount) virtual public returns (bool);
    function burn(uint256 _amount) virtual public returns (bool);

    function setAggregateOfferingPricePercentage(uint256 percentage) virtual external;
    function setFirstYearSecondarySalesLimitation(bool status,string memory reason) virtual external;
}