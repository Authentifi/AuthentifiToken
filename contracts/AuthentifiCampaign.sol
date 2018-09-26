pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

contract AuthentifiCampaign {

  event RecipientsSet(address _owner, bytes32 _name);
  event AuditorsFilled(address _owner, bytes32 _name);

  struct Recipient { //Recipient information
    bytes32 name; //short name
    bytes32 contactInfo; //phone number
  }

  struct Auditor { // Auditors
    address auditorWallet;
    uint recipientCount;
    bytes32[] recipientAuditList;
    mapping (uint => Recipient) Recipients;
    mapping(bytes32 => RecipientAudit) AuditStructs;
  }

  struct RecipientAudit { //an Audit of a recipient
    Recipient recipient; //the recipient
    uint checksum; //the checksummed value of what the auditor result was
    string result;
  }

  address public owner;
  bytes32 public name;
  uint public maxAuditors;
  uint public currentAuditorCount;
  mapping(address => bool) AcceptableAuditors;
  mapping(address => Auditor) public Auditors;
  mapping(uint => Recipient[]) Recipients;

  constructor(bytes32 _name) public {
    owner = msg.sender;
    name = _name;
  }

  function setAuditorCount(uint count) public { // the required number of auditors for an audit
    if (msg.sender == owner) {
      maxAuditors = count;
    }
  }

  function setAcceptableAuditors(address[] _accept) public { // this could be a call to a generic list of acceptable auditors elsewhere
    if (msg.sender == owner) {
      for (uint i = 0; i < _accept.length; i++) {
        AcceptableAuditors[_accept[i]] = true;
      }
    }
  }

  function setRecipients(Recipient[][] _recipients) public { //a 2d array of recipient lists
    if (msg.sender == owner) {
      for (uint i = 0; i <_recipients.length; i++) {
        for (uint j = 0; j < _recipients[i].length; j++) {
          Recipients[i].push(_recipients[i][j]);
        }
      }
      emit RecipientsSet(owner, name);
    }
  }

  function reserveAuditSpot() public {
    if ((AcceptableAuditors[msg.sender] && currentAuditorCount < maxAuditors) && (++currentAuditorCount > 0)) {  //checks if the auditors is approved, if the auditor count is low enough, and iterates the auditor count up by 1
      Auditors[msg.sender].auditorWallet = msg.sender;
      uint auditRef = currentAuditorCount;
      Auditors[msg.sender].recipientCount = Recipients[auditRef].length;
      for (uint i = 0; i < Recipients[auditRef].length; i++) {
        Auditors[msg.sender].Recipients[i] = Recipients[auditRef][i];
      }
    }
  }

  function auditRecipient(RecipientAudit audit) public {
    if (Auditors[msg.sender].recipientCount > 0) {
      Auditors[msg.sender].recipientAuditList.push(audit.recipient.contactInfo);
      Auditors[msg.sender].AuditStructs[audit.recipient.contactInfo] = audit;
    }
  }

}
