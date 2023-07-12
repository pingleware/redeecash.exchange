// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./IOfferingPool.sol";
import "./IBaseOffering.sol";

contract OfferingPool is IOfferingPool {

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    function getOwner() override external view returns (address) {
        return owner;
    }
    function assignToken(address tokenAddress, address issuer, string calldata name, string calldata symbol, uint256 totalSupply, string calldata regulation) override external isOwner {
        require(tokenContracts[symbol].tokenAddress == address(0), "Token already exists");

        tokenContracts[symbol] = Token(name,symbol,tokenAddress,regulation);

        emit AssignedOffering(owner,issuer,name,symbol,totalSupply);
    }
    function updateTokenName(string calldata symbol,string calldata name) override external isOwner {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        string memory oldName = tokenContracts[symbol].tokenName;
        tokenContracts[symbol].tokenName = name;

        emit UpdatedListingName(owner,oldName,name);
    }
    function updateTokenAddress(string calldata symbol,address tokenAddress) override external isOwner {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        address oldToken = tokenContracts[symbol].tokenAddress;
        tokenContracts[symbol].tokenAddress = tokenAddress;

        emit UpdatedListingAddress(owner,oldToken,tokenAddress);
    }
    function updateTokenOfferingType(string calldata symbol,string calldata offeringType) override external isOwner {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        string memory oldOfferingType = tokenContracts[symbol].tokenOfferingType;
        tokenContracts[symbol].tokenOfferingType = offeringType;

        emit UpdatedListingOfferingType(owner,oldOfferingType,offeringType);
    }
    function removeToken(string calldata symbol) override external isOwner {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        delete tokenContracts[symbol];
        emit DelistedToken(owner,symbol);
    }
    /**
     * NON_ACCREDITED = 0,
     * ACCREDITED = 1, AFFILIATE = 2, BROKER_DEALERS =  3, INSTITUTIONS = 4, MUNICIPALITIES = 5
     */
    function addInvestor(address investor, uint investor_type,string memory jurisdiction) override external isOwner {
        require(whitelisted[investor].active == false,"investor already exists");
        if (investor_type == 1) {
            accredited_investors.push(investor);
        } else if (investor_type == 2) {
            affiliate_investors.push(investor);
        } else if (investor_type == 3) {
            broker_dealers.push(investor);
        } else if (investor_type == 4) {
            institutions.push(investor);
        } else if (investor_type == 5) {
            municipalities.push(investor);
        } else {
            nonaccredited_investors.push(investor);
        }
        whitelisted[investor] = INVESTOR(msg.sender,true,jurisdiction,investor_type);
    }
    function getInvestors() override external view returns (address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory) {
        return (nonaccredited_investors,accredited_investors,affiliate_investors,broker_dealers,institutions,municipalities);
        
    }
    function getInvestor(address wallet) override external view returns (INVESTOR memory) {
        return whitelisted[wallet];
    }
    function getInvestorStatus(address wallet) override external view returns (bool) {
        return whitelisted[wallet].active;        
    }
    function getInvestorJurisdiction(address wallet) override external view returns (string memory) {
        return whitelisted[wallet].jurisdiction;
    }
    function getInvestorLevel(address wallet) override external view returns (uint) {
        return whitelisted[wallet].level;
    }
    function isAccredited(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<accredited_investors.length; i++) {
            if (accredited_investors[i] == wallet) return true;
        }
        return false;
    }
    function isNonAccredited(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<nonaccredited_investors.length; i++) {
            if (nonaccredited_investors[i] == wallet) return true;
        }
        return false;
    }
    function isAffiliate(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<affiliate_investors.length; i++) {
            if (affiliate_investors[i] == wallet) return true;
        }
        return false;
    }
    function isBrokerDealer(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<broker_dealers.length; i++) {
            if (broker_dealers[i] == wallet) return true;
        }
        return false;
    }
    function isTransferAgent(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<transfer_agents.length; i++) {
            if (transfer_agents[i] == wallet) return true;
        }
        return false;
    }
    function isInstitution(address wallet) override external view returns (bool) {
        for (uint256 i=0; i<institutions.length; i++) {
            if (institutions[i] == wallet) return true;
        }
        return false;
    }
    function isWhitelisted(address wallet) override external view returns (bool) {
        return whitelisted[wallet].active;
    }
}