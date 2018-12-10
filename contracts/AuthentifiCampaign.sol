pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

import './AuditToken.sol';

contract AuthentifiCampaign {

  event AuditorComplete(address _auditor, int _result);
  event AuditorsFilled(address _owner, bytes32 _name);
  event AuditorAdded(address _auditor, uint256 _tokens, address _thisOne);
  event FullAuditComplete(int _finalResult);
  event AuditorPaid(address _auditor, uint256 _tokens);
  event AuditorSlashed(address _auditor);

  struct Auditor { // Auditors
    address auditorWallet;
    bytes32 RecipientHash;
    int RecipientResults;
    bool resultSet;
    bool exists;
  }

  address public owner;
  AuthentifiAuditToken public auditContract;
  address public auditTokenAddress;
  bytes32 public name;
  uint public maxAuditors;
  uint public currentAuditorCount;
  uint256  public minimumTokens;
  mapping(address => Auditor) public Auditors;
  address[] public AuditorList;
  uint public resultsCount;
  int public finalResult;
  bytes32 public RecipientRootHash;

  constructor(bytes32 _name, address _acceptedTokens, uint256 _minTokens, bytes32 RootHash) public {
    owner = msg.sender;
    name = _name;
    auditContract = AuthentifiAuditToken(_acceptedTokens);
    auditTokenAddress = _acceptedTokens;
    minimumTokens = _minTokens;
    RecipientRootHash = RootHash;
    finalResult = 0;
  }

  function setAuditorCount(uint count) public { // the required number of auditors for an audit
    if (msg.sender == owner) {
      maxAuditors = count;
    }
  }

  function uploadRecipients(bytes32 recipientHash) public {
    if (Auditors[msg.sender].exists) {
      Auditors[msg.sender].RecipientHash = recipientHash;
    }
  }

  function uploadRecipientResults(int recipientResults) public {
    if (Auditors[msg.sender].exists) {
      Auditors[msg.sender].RecipientResults = recipientResults;
      if (!Auditors[msg.sender].resultSet) {
        Auditors[msg.sender].resultSet = true;
        resultsCount += 1;
      }
      emit AuditorComplete(msg.sender, recipientResults);
    }
    if (resultsCount >= maxAuditors && finalResult == 0) {
      int temp = 0;
      for (uint i = 0; i < AuditorList.length; i++) {
        temp += Auditors[AuditorList[i]].RecipientResults;
      }
      finalResult = temp / int(AuditorList.length);
      for (uint j = 0; j < AuditorList.length; j++) {
        if ( ((finalResult - Auditors[AuditorList[j]].RecipientResults) < 10) && ((finalResult - Auditors[AuditorList[j]].RecipientResults) > -10) ) { //the results are within 10
          auditContract.transfer(AuditorList[j], minimumTokens);
          emit AuditorPaid(AuditorList[j], minimumTokens);
        } else {
          emit AuditorSlashed(AuditorList[j]);
        }
      }
      emit FullAuditComplete(finalResult);
    }
  }

  function reserveAuditSpot() public {
    if (auditContract.allowance(msg.sender, address(this))>= minimumTokens && currentAuditorCount < maxAuditors) {  //checks if the auditor count is low enough, and iterates the auditor count up by 1
      auditContract.transferFrom(msg.sender, address(this), minimumTokens);
      Auditors[msg.sender].auditorWallet = msg.sender;
      Auditors[msg.sender].resultSet = false;
      Auditors[msg.sender].exists = true;
      AuditorList.push(msg.sender);
      emit AuditorAdded(msg.sender, minimumTokens, address(this));
    }
  }
}
