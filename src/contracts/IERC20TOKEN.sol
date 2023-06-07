// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract IERC20TOKEN {
    address public owner;
    address public issuer;

    function totalSupply() virtual public view returns (uint);
    function balanceOf(address tokenOwner) virtual public view returns (uint);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint);
    function transfer(address to, uint tokens) virtual public returns (bool);
    function approve(address spender, uint tokens) virtual public returns (bool);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool);
    function updateTransferAllocation(address issuer,address wallet,uint256 amount) virtual public;
    function checkWhitelisted() virtual public view returns (bool);
    function checkTransferAgent() virtual public view returns (bool);
    function getBalanceFrom(address wallet) virtual public view returns (uint256); 

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}