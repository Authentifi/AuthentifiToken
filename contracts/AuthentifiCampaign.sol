pragma solidity ^0.4.21;

contract AuthentifiCampaign {


  Struct Recipient { //Recipient information
    bytes32 name; //short name
    bytes32 contactInfo; //phone number
  }

  Struct Auditor { // Auditors
    address auditorWallet;
    bool reserved;
    bytes32[] recipientList;
    mapping(bytes32 => Recipient) RecipientStructs;
    mapping(bytes32 => RecipientAudit) AuditStructs;
  }

  Struct RecipientAudit { //an Audit of a recipient
    Recipient recipient; //the recipient
    uint checksum; //the checksummed value of what the auditor result was
    string result;
  }

  address public owner;
  string public name;
  mapping(address => Auditor) Auditors;

  constructor()




}
