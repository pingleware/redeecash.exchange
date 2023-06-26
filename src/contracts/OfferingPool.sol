// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
import "./Offering.sol";

contract OfferingPool {

    struct Token {
        string tokenName;
        string tokenSymbol;
        address tokenAddress;
        string tokenOfferingType;
    }

    mapping(string => Token) public tokenContracts;

    //mapping(address => mapping(string => uint256)) public investments;

    address owner;

    event CreatedNewOffering(address owner,address issuer,string name,string symbol,uint256 tokens,address catAddress,bool exemptOffering);
    event OfferingDeleted(string symbol);
    event AddedTransferAgent(address sender,address transferAgent);
    


    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    
    function createToken(address _issuer, string memory _name, string memory _symbol, uint _tokens, uint256 _price,address _catContractAddress,string memory _regulation,bool _exemptOffering) public isOwner returns(address) {
        require(tokenContracts[_symbol].tokenAddress == address(0), "Token already exists");

        address newToken = address(new Offering(owner,_issuer,_name,_symbol, _tokens, _price, _catContractAddress,_exemptOffering));

        tokenContracts[_symbol] = Token(_name,_symbol,newToken,_regulation);

        emit CreatedNewOffering(owner,_issuer,_name,_symbol,_tokens,_catContractAddress,_exemptOffering);

        return newToken;
    }

    function deleteToken(string calldata _symbol) external isOwner {
        require(tokenContracts[_symbol].tokenAddress != address(0x0),"no token contract exists");
        delete tokenContracts[_symbol];
        emit OfferingDeleted(_symbol);
    }

    function addTransferAgent(string memory symbol,address transferAgent) external isOwner {
        require(tokenContracts[symbol].tokenAddress != address(0x0),"token not found for symbol");
        IOffering token = IOffering(tokenContracts[symbol].tokenAddress);
        token.addTransferAgent(transferAgent);
        emit AddedTransferAgent(owner,transferAgent);
    }
}