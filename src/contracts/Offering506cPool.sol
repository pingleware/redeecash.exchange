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

    /**
     * The tokens created will have the owner as this contract or address(this)
     */
    function createToken(string memory name, string memory symbol, uint tokens, uint price) public isOwner {
        require(tokenContracts[symbol] == address(0), "Token already exists");

        uint256 offering = SafeMath.safeMul(tokens,price);
        require(offering <= 20000000,"exceeds the statutory maximum offering dollar amount");

        address newToken = address(new Offering506c(owner, name, symbol, tokens));
        tokenContracts[symbol] = newToken;
    }

    // attempting to invoke the token contract addTrasnferAgent directly using the tokenAddress, will
    // not work but report an empty success. Which is desirable as this prevents unethical users from
    // assigning themselves as a transfer agent and execute trades. The first safety protection on a
    // public blockchain.
    //
    // The following code snippet attempts to add a transfer agent, but fails
    //
    //      const contract = new web3.eth.Contract(JSON.parse(tokenABI), tokenAddress);
    //      const status = await contract.methods.addTransferAgent(transferAgent).call({from: poolContract});
    function addTransferAgent(string memory symbol,address transferAgent) public isOwner {
        require(tokenContracts[symbol] != address(0x0),"token not found for symbol");
        Offering506c token = Offering506c(tokenContracts[symbol]);
        token.addTransferAgent(transferAgent);
    }

}