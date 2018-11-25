# AuthentifiToken
Two Smart Contracts for Authentifi Auditing

# Quickstart

```
npm install -g truffle
truffle compile
truffle migrate
truffle develop OR truffle console
```

see truffle docs for more info: https://truffleframework.com/docs/truffle/quickstart#compiling

# AuthentifiAuditToken

An ERC-20 compliant Token for the privilege of staking audits

* balanceOf(address) Return current balance
* transfer(destination, value) Transfers tokens
* transferFrom(source, destination, value) Transfers tokens off credit
* approve(destination, value) Approves a token on credit
* allowance(source, destination) Returns current credit

# AuthentifiCampaign

A Campaign contract that contains recipient's in a hashed merkle tree, the hashedaudits of those recipients, and the root hash of the recipient tree

* setAuditorCount(count) Set the number of auditors needed for auditing to begin
* reserveAuditSpot() Auditor reserves a spot using tokens set for credit
* uploadRecipients(hash) Auditor submits an off chain sourced list of recipients, hashed so as to validate the root merkle tree hash
* uploadRecipientResults() Auditor submits the recipient results hashed for the purpose of verifying completion and veracity of other sources of the results in future

## Short summary of auditor flow

Auditors stake tokens on a campaign in order to reserve auditing slots within that campaign

Recipients are assigned to auditors

Auditors submit audits on assigned recipients (anonymized)

Audits are resolved together

Results are released publicly
