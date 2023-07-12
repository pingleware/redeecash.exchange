// Corporate Bond Smart Contract

// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract CorporateBond {
    struct BondHolder {
        address holderAddress;
        uint256 investedAmount;
    }

    string public name; // Name of the corporate bond
    address public issuer; // Address of the bond issuer
    uint256 public principal; // Principal amount of the bond
    uint256 public couponRate; // Annual coupon rate (in basis points)
    uint256 public maturityDate; // Unix timestamp of the bond maturity date
    uint256 public bondRating; // Bond rating of the issuer (on a scale of 1 to 10)

    BondHolder[] public bondHolders;

    constructor(
        string memory _name,
        uint256 _principal,
        uint256 _couponRate,
        uint256 _maturityDate,
        uint256 _bondRating
    ) {
        name = _name;
        issuer = msg.sender;
        principal = _principal;
        couponRate = _couponRate;
        maturityDate = _maturityDate;
        bondRating = _bondRating;
    }

    // Function to calculate the coupon payment
    function calculateCouponPayment() public view returns (uint256) {
        require(block.timestamp < maturityDate, "Bond has matured");
        uint256 timeRemaining = maturityDate - block.timestamp;
        uint256 couponPayment = (principal * couponRate * timeRemaining) / (100 * 365 days);
        return couponPayment;
    }

    // Function to calculate the bond rating based on the issuer's credit rating
    function calculateBondRating() public view returns (string memory) {
        if (bondRating >= 9) {
            return "AAA";
        } else if (bondRating >= 8) {
            return "AA";
        } else if (bondRating >= 7) {
            return "A";
        } else if (bondRating >= 6) {
            return "BBB";
        } else if (bondRating >= 5) {
            return "BB";
        } else if (bondRating >= 4) {
            return "B";
        } else if (bondRating >= 3) {
            return "CCC";
        } else if (bondRating >= 2) {
            return "CC";
        } else if (bondRating == 1) {
            return "C";
        } else {
            return "Not Rated";
        }
    }

    // Function to make coupon payments to the bondholders
    function makeCouponPayment() external {
        require(msg.sender == issuer, "Only the issuer can make coupon payments");
        require(block.timestamp < maturityDate, "Bond has matured");
        uint256 couponPayment = calculateCouponPayment();

        for (uint256 i = 0; i < bondHolders.length; i++) {
            BondHolder storage holder = bondHolders[i];
            (bool success, ) = holder.holderAddress.call{value: (couponPayment * holder.investedAmount) / principal}("");
            require(success, "Failed to send coupon payment");
        }
    }

    // Function to redeem the bond and return the principal to the bondholders
    function redeemBond() external {
        require(msg.sender == issuer, "Only the issuer can redeem the bond");
        require(block.timestamp >= maturityDate, "Bond has not matured");

        for (uint256 i = 0; i < bondHolders.length; i++) {
            BondHolder storage holder = bondHolders[i];
            (bool success, ) = holder.holderAddress.call{value: (principal * holder.investedAmount) / principal}("");
            require(success, "Failed to send bond redemption");
        }
        
        delete bondHolders;
    }

    // Function to allow bondholders to purchase the bond
    function purchaseBond(uint256 investedAmount) external payable {
        require(msg.value == investedAmount, "Incorrect bond amount");
        require(investedAmount <= principal, "Invested amount exceeds the principal");

        bondHolders.push(BondHolder(msg.sender, investedAmount));
    }
}
