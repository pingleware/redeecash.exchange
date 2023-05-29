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

Since these filings are voluntary for non-public companies, an audit by an independent CPA is voluntary and not required. A managerial audit is encouraged using an algorithmic auditing tool such as https://github.com/pingleware/bestbooks-auditor

## Company Reporting

A company does not need to be listed on the RedeeCash Exchange to submit reports as long as they have an active Regulation D or A Tier 1 offering on the SEC EDGAR system and is NOT a public company. There is no charge for submitting reports.

The application to assist in creating the corresponding XML file will be distributed at https://github.com/pingleware/redeecash.exchange.reorting
