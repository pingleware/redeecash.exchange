// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./BaseOffering.sol";

abstract contract IOffering is BaseOffering {
    string public DESCRIPTION = string("TO BE DEFINED");
    bool public EXEMPT_OFFERING = false;
    bool public RESTRICTED_SECURITY = false;
    bool public RULE144_TRANSFERS = false;

    string public CUSIP = string("TO BE ASSIGNED");
    string public SEC_FILENUMBER = string("000-00000");
    uint256 public MAX_OFFERING = 0;
    uint256 public MAX_OFFERING_SHARES = 0; // based on the maximum allowance offering and intial share price

    function getMaxOffering() virtual public view returns(uint256);
    function transfer(address to, uint tokens) virtual override public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual override public returns (bool success);
    function mint(uint256 _amount) virtual public returns (bool);
    function burn(uint256 _amount) virtual public returns (bool);
    function setCUSIP(string memory cusip) virtual override public;
    function setSECFilenumber(string memory fileNumber) virtual override public;
    function setMaxOffering(uint256 value) virtual override public;
    function setMaxShares(uint256 value) virtual override public;

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Withdrawal(address indexed recipient, uint256 amount);
    event Deposit(address indexed sender, uint256 amount);

}