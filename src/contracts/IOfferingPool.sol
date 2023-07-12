// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract IOfferingPool {
    struct INVESTOR {
        address wallet;
        bool active;
        string jurisdiction;
        uint level;
    }

    struct Token {
        string tokenName;
        string tokenSymbol;
        address tokenAddress;
        string tokenOfferingType;
    }

    mapping(address => INVESTOR) public whitelisted;
    mapping(string => Token) public tokenContracts;

    address owner;

    address[] accredited_investors;
    address[] nonaccredited_investors;
    address[] affiliate_investors;
    address[] broker_dealers;
    address[] transfer_agents;
    address[] institutions;
    address[] municipalities;


    event AssignedOffering(address,address,string,string,uint256);
    event UpdatedListingAddress(address owner,address oldToken,address newToken);
    event UpdatedListingName(address owner,string oldName,string newName);
    event UpdatedListingOfferingType(address owner,string oldOfferingType,string newOfferingType);
    event DelistedToken(address owner,string symbol);
    event TransferAgentAdded(address sender,address transferAgent);

    function getOwner() virtual external view returns (address);
    function assignToken(address tokenAddress, address issuer, string calldata name, string calldata symbol, uint256 totalSupply, string calldata regulation) virtual external;
    function updateTokenName(string calldata symbol,string calldata name) virtual external;
    function updateTokenAddress(string calldata symbol,address tokenAddress) virtual external;
    function updateTokenOfferingType(string calldata symbol,string calldata offeringType) virtual external;
    function removeToken(string calldata symbol) virtual external;
    function addInvestor(address investor, uint investor_type,string memory jurisdiction) virtual external;
    function getInvestors() virtual external view returns (address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory);
    function getInvestor(address wallet) virtual external view returns (INVESTOR memory);
    function getInvestorStatus(address wallet) virtual external view returns (bool);
    function getInvestorJurisdiction(address wallet) virtual external view returns (string memory);
    function getInvestorLevel(address wallet) virtual external view returns (uint);
    function isAccredited(address wallet) virtual external view returns (bool);
    function isNonAccredited(address wallet) virtual external view returns (bool);
    function isAffiliate(address wallet) virtual external view returns (bool);
    function isBrokerDealer(address wallet) virtual external view returns (bool);
    function isTransferAgent(address wallet) virtual external view returns (bool);
    function isInstitution(address wallet) virtual external view returns (bool);
    function isWhitelisted(address wallet) virtual external view returns (bool);
}