# Contracts for Redeecash Exchange

There are two main contracts, OfferingPool and ConsolidatedAuditTrail. The OfferingPool is the main contract for the Redeecash Exchange which has the investor classification and their trade status. The intent is for the Redeecash Exchange to perform the KYC/AML on all participants and make the results available to the Issuer offering contracts, enforcing that no offering may use independent KYC/AML but reference by the investor in the OfferingPool.

ConsolidatedAuditTrail is a public repository for maintaining the transaction history of all offerings by their symbol.

When an issuer creates a new offering, they will create a new Offering contract inheriting the BaseOffering contract and provides the custom metadate for the offering based on the regulation of the offering.

Each new offering must be accompanied with a separate OrderBook contract referencing the issuer Offering contract the public ConsolidatedAuditTrail. The issuer will deploy these two contracts on the blockchain, change the ownership to Redeecash Exchange wallet and submit the contract addresses to Redeecash Exchange through the issuer DAPP.
