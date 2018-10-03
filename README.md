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

A Campaign contract that contains recipient's anonymized contact info, the audits of those recipients, and the results of the overall audit

* migrateToken(address) New address of a migrated Token contract (last resort)
* setAuditorCount(count) Set the number of auditors needed for auditing to begin
* setRecipients(recipient) Set a recipient list for auditors to audit
* reserveAuditSpot() Auditor reserves a spot using tokens set for credit
* auditRecipient(audit) Auditor submits a recipient audit
* auditResults() Returns the results of the audit of the campaign

## Short summary of auditor flow

Auditors stake tokens on a campaign in order to reserve auditing slots within that campaign
Recipients are assigned to auditors
Auditors submit audits on assigned recipients (anonymized)
Audits are resolved together
Results are released publicly
