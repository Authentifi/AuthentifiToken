pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

contract AuthentifiCampaign {

  event RecipientsSet(address _owner, bytes32 _name);
  event AuditorsFilled(address _owner, bytes32 _name);

  struct Recipient { //Recipient information
    bytes32 name; //short name
    bytes32 contactInfo; //phone number
    int[] auditorsToAssign;
  }

  struct Auditor { // Auditors
    address auditorWallet;
    bool reserved;
    bytes32[] recipientList;
    uint[] Recipients;
    mapping(bytes32 => RecipientAudit) AuditStructs;
  }

  struct RecipientAudit { //an Audit of a recipient
    Recipient recipient; //the recipient
    uint checksum; //the checksummed value of what the auditor result was
    string result;
  }

  address public owner;
  bytes32 public name;
  int public maxAuditors;
  mapping(address => Auditor) Auditors;
  mapping(uint => Recipient) Recipients;

  constructor(bytes32 _name) public {
    owner = msg.sender;
    name = _name;
  }

  function setAuditorCount(int count) public {
    if (msg.sender == owner) {
      maxAuditors = count;
    }
  }
  function setRecipients(Recipient[] _recipients) {
    _recipients.forEach()
    emit RecipientsSet(owner, name);
  }


}
