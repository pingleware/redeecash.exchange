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

import "./OfferingS1.sol";

contract OfferingS1Pool {
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

        if (price > 0) {}

        address newToken = address(new OfferingS1(name, symbol, tokens));
        tokenContracts[symbol] = newToken;
    }
}