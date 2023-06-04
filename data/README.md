# RedeeCash Exchange Data

This folder will hold the entity voluntary reporting that is not offered by the SEC EDGAR system.

The directory structure top level will be the SEC assigned filer CIK followed by the SEC assigned file number and each file with a unique filename suffixed with the filing type.

## New Filing Types

Since the SEC EDGAR does not offer voluntary reporting of annual and quarterly reports for a Regulation D or A Tier 1, the following new filing report types will be created in this repository,

* Form D-Q as the voluntary quarterly reporting for a Regulation D exempt offering
* Form D-K as the voluntary annual reporting for a Regulation D exempt offering
* Form A1-Q as the voluntary quarterly reporting for a Regulation A Tier 1 offering
* Form A1-K as the voluntary annual reporting for a Regulation A Tier 1 offering

The data format will be XML

## Audit Requirements

Since these filings are voluntary for non-public companies, an audit by an independent CPA is voluntary and not required. A managerial audit is encouraged using an algorithmic auditing tool such as https://github.com/pingleware/bestbooks-auditor.

A ConsolidatedAuditTrail contract is created and updated during transfers, miniting and burning of tokens. Audit trail is retreived by symbol.

## Company Reporting

A company does not need to be listed on the RedeeCash Exchange to submit reports as long as they have an active Regulation D or A Tier 1 offering on the SEC EDGAR system and is NOT a public company. There is no charge for submitting reports.

The application to assist in creating the corresponding XML file will be distributed at https://github.com/pingleware/redeecash.exchange.reorting

## Private Network

### Example of using Regulation A Tier 1 offering

1. Clone this project
2. Start remix and copy OfferingRegAT1.sol to the IDE
3. Start GANACHE, cd src && npm run start:ganache
4. Connect to Dev - Ganache in remix
5. On deploy panel of remix, paste contract address at0x857e03790286dc4a8ca27Fba5777d8A1b9c2df69 to 'At Address' parameter below the Deploy and press the 'At Address', you should see the contract in the Deployed Contracts section

Adding a non-accredited investor,

1. Copy another wallet address
2. Paste in the investor parameter of the Add Investor method and set the investor type paramter to 0, then press the Transact button
3. The wallet is now whitelisted as an non-accredited investor

Sending equity tokens to the new investor,

1. Assuming the investor had already paid for the shares off-chain, from the owner address, copy the investor wallet to the investor parameter of the Approve method
2. Set the tokens parameter to the number of shares that you need to transfer, and press the transact button

Performing the actual transfer,

1. From the owner address, copy the investor wallet and paste in 'to' parameter of the trasnfer method, and set the tokens parameter to the same amount as the 'approve' method, then press transact button
2. The investor now has the tokens and the owner balance has been decreased.
3. The investor may now freely trade these tokens with other whitelisted investors. The investor holds the tokens in their own wallet, making this non-custodial.

Checking the balances,

1. Copy the wallet address and paste in tokenOwner parameter of the balanceOf method and press trsnact button
2. The balance is displayed

Checking the remaining of allowance approvals,

1. When not transferring all approve token allowances at one time, there is balance and can be checked using the allowance method, copy the investor wallet to the tokenOwner parameter
2. Copy the owner waller to spender parameter
3. Press the transact button
4. The remaining balance of the allowance is displayed

Using an independent transfer agent to conduct the token transfers,

The independent transfer agent, will use approveTransaction and transferFrom, when the transfer agent does not hold any tokens and the contract owner holds the tokens to be transfered. The independent transfer agent can use approve and transfer, after the contract owner has transferred tokens to the transfer agent wallet. The issuer (contract owner) may act as the transfer agent for it's own securities, and should file form TA-1 with the SEC.

1. This contract 0x4538b543542e72c24AF7CBD67444270Bb0548eD5, only permits the whitelisted transfer agent to transfer tokens between wallets. The owner (which is also the issuer) is whitelisted as a transfer agent.
2. Whitelist an investor
3. The whitelisted investor can invoke approve method to indicate a buy or sell, but only the transfer agent can perform the actual transfer.
4. Whitelist a wallet as an independent transfer agent
5. Switch to the investor wallet and make a requestBuy for a 100 tokens
6. Switch to the transfer agent wallet and approveTransaction using the owner wallet, the selected investor and 100 tokens
7. Verify the allowance with the tokenOwner as the owner and spender as the investor, the result is 100
8. Invoke a transferFrom where from is the owner wallet, to is the investor wallet and tokens are the amount
9. Verify balance of owner wallet has decreased and investor wallet has increased.
10. Invoke resetBuy with investor wallet to reset the buy queue for the investor.

### Offering Pools

The following offering pools, which is a contract that can create unllimited offerings of a specific type, are included with their contract address,

1. OfferingRegAT1Pool at **0x185a178FE8F5BDCf49a9e045327f662D48599eD9**
2. Offering506bPool at **0xF383318a2a33010a5DCFEa8e2C919A2cdAA6441F**
3. Offering506cPool at **0xE9d103e4231c3A0576Ff8E3Fa4cc77F05b7917db**
4. OfferingS1Pool at **0x6DFDD215e3d4330c878e6F4C189C9F3dfD6A6F24**
5. Spot Currency Order Book at **0x599aD94A656574a7DAEE33C104501a447dF6709f** [Token: RCDCRC-5C  Address: **0x50fF7fa753C23c433bF37B65772d991e576B8129****]**
6. Oracle at **0x7e6EE5709CECec29d5c8Aa6F40ABDbdc9e1BA347**
7. ConsolidateAuditTrail at **0x0378124Da4FCb98F5ED7F142249D9E0F67125E71**

### Connectine with REMIX

Start GANACHE,

    npm run start:ganache

then

    Choose Dev - Ganache Provider

from remix.

### Ganache Accounts

    (0) 0x5EaF72deD2e4E255C228f9070501974D3572c5d4 (1000 ETH) - CONTRACT OWNER
	(1) 0xbd7a53B05592497624d71f0fF9e12AdCc20c69d6 (1000 ETH)
	(2) 0xa2A1F479f07e4740313B0C26572Ab13F50b9C362 (1000 ETH)
	(3) 0xd207749b84789589e23862eba08bbc67575dcd8D (1000 ETH)
	(4) 0xcad03280783FD62AD39Bd5431A8888F2BF110c83 (1000 ETH)
	(5) 0x490e7f14f80807df3f814331D48103BEC8eD03bf (1000 ETH)
	(6) 0x9F30e3755035dcaf201b2b48C85F0a4649E7a9ba (1000 ETH)
	(7) 0x9F20c037AE4BFd199fA06ddC8ca80784FB03D3E1 (1000 ETH)
	(8) 0xAa0a4029fa961823e4a2a64AaB39F9e4f5c2fAE8 (1000 ETH)
	(9) 0xB72621c155fB0d8Dcc9b65301FeB35618aF3d8Eb (1000 ETH)

#### Private Keys

    (0) 0x5be1b3c4bbbfefc377b2df9855a4c794a88a922a672dd0b4c3b9d42a9b52a882
	(1) 0x2c6583a8c7c85d1adb8edd8c6724dde66fd3de4fbe4dcab2a61d8b645fea82a2
	(2) 0x8199ecf0af7f89fd113cd4a796396179f93799d8fd6700c5c3b694061b3ff2b7
	(3) 0xce911ea3777f1bc87cbcdbad2b4415cca8dd082880240b5db749c1182e81f9a3
	(4) 0x92671a9acad83fe339c493a8ddb4aea253bf6588c29d868e6f47992891df6819
	(5) 0x3f90950da708837c5c51bd37c82284aa435e8097a1bea276a9a98b003639007d
	(6) 0x306dcb87fea6b234cfbf2b2abd6402f7417d958332f4befe77a46795dd1585db
	(7) 0xbfbf95bb7be96d1a63a47f0f5427b6912c1e37dd6ad2f01269b65b9b42123d89
	(8) 0xe38c3c5e534d1fdd99578273e8c87632751e31cf697b18958699c0fe6accf966
	(9) 0xe3842bbb108f91968ff4e2debb98f4a17ce3bdbcfaf443a68c149833d0b676bb
