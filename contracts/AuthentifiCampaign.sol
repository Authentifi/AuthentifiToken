pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

import './AuditToken.sol';

contract AuthentifiCampaign {

  event AuditorComplete(address _auditor, int _result); // Event for an auditor completing their audit
  event AuditorsFilled(address _owner, bytes32 _name); // Event for when all auditors are filled
  event AuditorAdded(address _auditor, uint256 _tokens, address _thisOne);  // Event for when an auditor is added
  event FullAuditComplete(int _finalResult); // Event for when all auditors are complete
  event AuditorPaid(address _auditor, uint256 _tokens); // Event for when an Auditor is paid
  event AuditorSlashed(address _auditor);  // Event for when an Auditor has their tokens slashed

  struct Auditor { // Auditors
    address auditorWallet; // The Auditor wallet
    bytes32 RecipientHash; // The Recipient hash, a hash value of the recipients to be audited
    int RecipientResults; // The Recipient result, a percentage value in integer form
    bool resultSet; // a t/f to see if the result has been set yet by the auditor, int typecasting to bool would not suffice, default false
    bool exists;  // a t/f to see if this auditor exists, solidity does not have a struct->bool type cast, so this is necessary
  }

  address public owner;  // owner of the campaign
  AuthentifiAuditToken public auditContract; // the audit token contract to be used (important in cases of migrations)
  address public auditTokenAddress; // the address of the audit token contract
  bytes32 public name; // name of the campaign
  uint public maxAuditors; // maximum auditor count
  uint public currentAuditorCount; // current auditor count
  uint256  public minimumTokens; // minimum tokens required to audit
  mapping(address => Auditor) public Auditors; // Auditor address mapping
  address[] public AuditorList; // the list of auditor addresses to support iteration
  uint public resultsCount; // the count of results submitted
  int public finalResult; // the final result as an int percentage
  bool complete;
  bytes32 public RecipientRootHash; // the root hash of recipients

  // initial constructor
  constructor(bytes32 _name, address _acceptedTokens, uint256 _minTokens, bytes32 RootHash) public {
    owner = msg.sender; // owner of the campaign
    name = _name; // name of the campaign
    auditContract = AuthentifiAuditToken(_acceptedTokens); // set audit contract
    auditTokenAddress = _acceptedTokens; // address of token contract
    minimumTokens = _minTokens; // minimum tokens
    RecipientRootHash = RootHash; // root hash for recipients
    finalResult = 0; // the final percentage result
    complete = false;
  }

  // set the max auditor count
  function setAuditorCount(uint count) public { // the required number of auditors for an audit
    if (msg.sender == owner) {
      maxAuditors = count; // the maximum auditors
    }
  }

  // set the recipient hash by auditor address
  function uploadRecipients(bytes32 recipientHash) public {
    if (Auditors[msg.sender].exists) {
      Auditors[msg.sender].RecipientHash = recipientHash;
    }
  }

  // Auditor uploads their results
  function uploadRecipientResults(int recipientResults) public {
    // If the sender is an auditor and the process isn't finished, set the results value
    if (Auditors[msg.sender].exists && !complete) {
      Auditors[msg.sender].RecipientResults = recipientResults;

      // If the result was not set before, iterate the count up, set the resultSet boolean to true, and send out an auditor complete event
      if (!Auditors[msg.sender].resultSet) {
        Auditors[msg.sender].resultSet = true;
        resultsCount += 1;
        emit AuditorComplete(msg.sender, recipientResults);

        // if this is the last auditor to submit, run the final validation and set the final result, paying back auditors close to the final result
        if (resultsCount >= maxAuditors && finalResult == 0) {
          int temp = 0;
          for (uint i = 0; i < AuditorList.length; i++) {
            temp += Auditors[AuditorList[i]].RecipientResults;
          }
          finalResult = temp / int(AuditorList.length);  // find the average to make the result
          for (uint j = 0; j < AuditorList.length; j++) {
            /*
             * iterate over auditors checking proximity to final result,
             * this is a placeholder, ideally we would have an expected deviation and use that
             * and we would use an exponential formula around that expected deviation with neighbors to determine slashing
             * for now a constant serves our purpose
            */
            if ( ((finalResult - Auditors[AuditorList[j]].RecipientResults) < 10) && ((finalResult - Auditors[AuditorList[j]].RecipientResults) > -10) ) { //the results are within 10
              auditContract.transfer(AuditorList[j], minimumTokens);
              emit AuditorPaid(AuditorList[j], minimumTokens); // emit auditor paid event
            } else {
              emit AuditorSlashed(AuditorList[j]); // emit auditor slashed event
            }
          }
          emit FullAuditComplete(finalResult);  // emit the audit as complete with the final value
          complete = true; // set the campaign as complete
        }
      }
    }
  }

  function reserveAuditSpot() public {
    //checks if the auditor count is low enough, and the auditor has enough tokens
    if (auditContract.allowance(msg.sender, address(this))>= minimumTokens && currentAuditorCount < maxAuditors) {
      auditContract.transferFrom(msg.sender, address(this), minimumTokens); //transfers the tokens to this contract
      Auditors[msg.sender].auditorWallet = msg.sender;
      Auditors[msg.sender].resultSet = false;
      Auditors[msg.sender].exists = true;
      currentAuditorCount += 1;
      AuditorList.push(msg.sender);
      emit AuditorAdded(msg.sender, minimumTokens, address(this));
    }
  }
}
