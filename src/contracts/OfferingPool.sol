// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Offering506b.sol";
import "./Offering506c.sol";
import "./OfferingRegAT1.sol";

contract OfferingPool {
    struct Token {
        string name;
        string symbol;
        address contractAddress;
        string offeringType;
    }

    mapping(string => Token) public tokenContracts;
    mapping(address => bool) public isToken;
    Token[] public tokens;

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    function createTokenRegAT1(string memory name, string memory symbol, uint _tokens, uint price) public isOwner {
        require(tokenContracts[symbol].contractAddress == address(0), "Token already exists");

        uint256 offering = SafeMath.safeMul(_tokens,price);
        require(offering <= 20000000,"exceeds the statutory maximum offering dollar amount");

        address newToken = address(new OfferingRegAT1(name, symbol, _tokens));
        tokenContracts[symbol] = Token(name,symbol,newToken,string("REGAT1"));
    }

    function createTokenRegD506b(string memory name, string memory symbol, uint _tokens, uint price) public isOwner {
        require(tokenContracts[symbol].contractAddress == address(0), "Token already exists");

        uint256 total = SafeMath.safeMul(_tokens,price);
        Offering506b offering = new Offering506b(name, symbol, _tokens);
        require(total <= offering.getMaxOffering(),"exceeds the statutory maximum offering dollar amount");

        address newToken = address(offering);
        tokenContracts[symbol] = Token(name,symbol,newToken,string("506B"));
    }

    function createTokenRegD506c(string memory name, string memory symbol, uint _tokens, uint price) public isOwner {
        require(tokenContracts[symbol].contractAddress == address(0), "Token already exists");

        uint256 total = SafeMath.safeMul(_tokens,price);
        Offering506c offering = new Offering506c(name, symbol, _tokens);
        require(total <= offering.getMaxOffering(),"exceeds the statutory maximum offering dollar amount");

        address newToken = address(offering);
        tokenContracts[symbol] = Token(name,symbol,newToken,string("506B"));
    }

}