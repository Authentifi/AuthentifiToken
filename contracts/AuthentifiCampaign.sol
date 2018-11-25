pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

import './AuditToken.sol';

contract AuthentifiCampaign {

  event AuditorComplete(address _auditor, bytes32 _hash);
  event AuditorsFilled(address _owner, bytes32 _name);
  event AuditorAdded(address _auditor, uint256 _tokens, address _thisOne);

  struct Auditor { // Auditors
    address auditorWallet;
    bytes32 RecipientHash;
    bytes32 RecipientResults;
  }

  address public owner;
  AuthentifiAuditToken public auditContract;
  address public auditTokenAddress;
  bytes32 public name;
  uint public maxAuditors;
  uint public currentAuditorCount;
  uint256  public minimumTokens;
  mapping(address => Auditor) public Auditors;
  bytes32 public RecipientRootHash;

  constructor(bytes32 _name, address _acceptedTokens, uint256 _minTokens, bytes32 RootHash) public {
    owner = msg.sender;
    name = _name;
    auditContract = AuthentifiAuditToken(_acceptedTokens);
    auditTokenAddress = _acceptedTokens;
    minimumTokens = _minTokens;
    RecipientRootHash = RootHash;
  }

  function setAuditorCount(uint count) public { // the required number of auditors for an audit
    if (msg.sender == owner) {
      maxAuditors = count;
    }
  }

  function uploadRecipients(bytes32 recipientHash) public {
    if (Auditors[msg.sender]) {
      Auditors[msg.sender].RecipientHash = recipientHash;
    }
  }

  function uploadRecipientResults(bytes32 recipientResults) public {
    if (Auditors[msg.sender]) {
      Auditors[msg.sender].RecipientResults = recipientResults;
      emit AuditorComplete(msg.sender, recipientResults)
    }
  }

  function reserveAuditSpot() public {
    if (auditContract.allowance(msg.sender, address(this))>= minimumTokens && currentAuditorCount < maxAuditors) {  //checks if the auditor count is low enough, and iterates the auditor count up by 1
      auditContract.transferFrom(msg.sender, address(this), minimumTokens);
      Auditors[msg.sender].auditorWallet = msg.sender;
      emit AuditorAdded(msg.sender, minimumTokens, address(this));
    }
  }
}
