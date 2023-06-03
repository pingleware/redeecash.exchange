# redeecash.exchange

Future of Registered National Securities Exchange for Cryptocurrency Token Trading

## Registering a NMS Exchange

Begins with filing the SEC Form 1. The initial, unfilled cover page has been included,

![1684506017789](image/README/1684506017789.png)

## SEC Self-Regulatory Organization Rulemaking

    See https://www.sec.gov/rules/sro.shtml

    NMS Regulation Final Rule - https://www.sec.gov/rules/final/34-51808.pdf

    Consolidate Auditing Trail - https://www.catnmsplan.com/about-cat

    Enforcement Manual - https://www.sec.gov/divisions/enforce/enforcementmanual.pdf

**Under 5.6.2 Informal Referrals to Self-Regulatory Organizations**,

*Bssics*:

In the course of conducting an inquiry or investigation, the staff may determine that it would be appropriate to refer the matter, or certain conduct, informally to one or more SROs. In particular, if an inquiry or investigation concerns matters over which SROs have enforcement  authority (e.g., financial industry standards, rules and requirements related to securities trading and brokerage), staff should evaluate whether to contact the SRO about the matter and assess whether it would be appropriate for the SRO to consider investigating the matter in lieu of, or in addition to, an SEC Enforcement investigation. Because SROs may impose disciplinary or remedial sanctions against their members or associated individuals, staff generally should make an effort to apprise the SRO about conduct that may violate the rules of the SRO. Internally, staff generally should consult as needed with OMI and/or the Division of Trading and Markets in evaluating potential informal referrals to SROs.

If there is a matter or conduct that appears to warrant an informal referral, staff generally should follow the procedures below:

* Assigned staff must obtain approval at the Associate Director, Unit Chief, or Associate Regional Director level to refer the matter or conduct informally.
* Once given approval, assigned staff, along with their supervisors, may notify the appropriate liaison at the SRO to discuss the matter or conduct, and a possible informal referral.
* Staff then may invite the SRO to make an access request (see Section 5.1 of the Manual regarding access requests). When the access request has been approved, staff may share documents from the investigative file. Staff may not forward documents to the SRO prior to the approval of the access request.
* After an informal referral to an SRO is made, staff should maintain periodic communication with the SRO concerning the status of the SRO inquiry or investigation and periodically assess whether any or additional SEC Enforcement measures should be taken.

*Considerations*:

* Staff should evaluate whether an informal referral is warranted in the early stages of an inquiry or investigation. As the investigation progresses, the staff should periodically  review the record to determine whether a new or additional informal referral may be  appropriate.
* Staff should make efforts to continue communicating with SRO staff throughout the SRO’s inquiry or investigation to determine whether SEC staff and SRO staff are investigating the same conduct, and so that SEC staff is aware of any determination by the SRO not to pursue an investigation or certain avenues of investigation.

*Further Information*:

* Staff should contact their supervisors and/or OMI with any questions about making an informal referral to an SRO.
* For guidance regarding receiving referrals from an SRO, see Section 2.2.2.5 of the Manual.

## Consolidated Audit Trail

Each NMS must submit a mapping of CAT Report fields to Exchange-related fields, see [Order and Quote RoutingField Mapping between CAT and Exchanges/Display-Only](https://www.catnmsplan.com/sites/default/files/2023-04/4.11.23_Order_Routing_Field_Mapping_between_CAT_and_Exchanges_v2.6.pdf) and [https://www.sec.gov/divisions/marketreg/rule613-info](https://www.sec.gov/divisions/marketreg/rule613-info)

| CAT Report Field | RedeeCash Exchange-related Field        |
| ---------------- | --------------------------------------- |
| senderIMID       | wallet address                          |
| routedOrderID    | the transaction hash                    |
| symbol           | the registered symbol, e.g. RCDCRC-5C  |
| eventTimestamp   | ISO zulu form (ISO 8601)                |
| session          | Will contain the blockchain transaction |

the above is subject to change until approved.

An issue that will need to be resolve with the NMS Plan submission, is the Prohibition Use of Account Numbers ([https://www.sec.gov/rules/sro/nms/2020/34-89397.pd](https://www.sec.gov/rules/sro/nms/2020/34-89397.pd)f), as the wallet address used to interact with the blockchain is consider an account number as it is unique to the user, and the only public personal information available on the blockchain networks. No other personal identifying information is published, with the public nature of the blockchain, anyone can view tje activity of any wallet. A waiver would need to requested and approved for a blockchain NMS to use the wallet address. The options include custodial operations, where the wallet address is that of the NMS; Pooled account trading with disbursements performed off-chain, again the wallet address is that of the NMS and after each trade, transfers initiated appropriately (an investor still holds their own tokens, but when selling, must tranfer to a trading wallet owned by the NMS or broker-dealer, that will execute the trade. When buying, the trading wallet initiates the buy order with an off chain reference to investor wallet and upon fulfillment, the trading wallet will transfer to the investor wallet.);

    A. Prohibition on Use of Account Numbers

    The Participants propose to amend the definition of Firm Designated ID to prohibit the
use of account numbers as Firm Designated IDs for accounts that are not proprietary accounts.
After discussions with the industry, the Participants have concluded that each Industry Member
must make its own risk determination as to whether it believes it is necessary to mask the actual
account number for any proprietary account of the Industry Member when reporting the Firm
Designated ID to CAT.

**Resolution using a single trading wallet**:

The senderIMID would then be the trading wallet, and an offchain record maintained to correlate the transaction and the investor wallet/account, when the CAT is NOT confidential. For confidential CAT reporting the senderIMID would be the investor wallet. However, unless a waiver can be obtained permitting the use of wallet addresses, then the NMS must be a custodial-based system and trading is restricted to registered broker-dealers whp maintain custody of the investor tokens. See [Custody of Funds or Securities of Clients by Investment Advisers](https://www.sec.gov/rules/final/ia-2176.htm).

## About RedeeCash Exchange

An initial overview of the RedeeCash Exchange registration,

[RedeeCash Exchange Overview](files/RedeeCash_Exchange.pdf)

[Using Blockchain for Private Equity under Rule 506b](files/blockchain_rule506b.pdf) 

[Digital Asset Market Structure Discussion Draft](files/HHRG-118-AG00-20230606-SD002.pdf)

Assigned staff should consult initially with their direct supervisors, as well as OMI and/or

  the Division of Trading and Markets, as appropriate.
