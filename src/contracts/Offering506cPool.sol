// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Offering506c.sol";

contract Offering506cPool {
        mapping(string => address) public tokenContracts;

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"unauthorized, accessible only by owner");
        _;
    }

    function createToken(string memory name, string memory symbol, uint tokens, uint price) public isOwner {
        require(tokenContracts[symbol] == address(0), "Token already exists");

        uint256 offering = SafeMath.safeMul(tokens,price);
        require(offering <= 20000000,"exceeds the statutory maximum offering dollar amount");

        address newToken = address(new Offering506c(name, symbol, tokens));
        tokenContracts[symbol] = newToken;
    }

}