pragma solidity ^0.4.21;

contract AuthentifiAuditToken {

  /*  Authentifi Audit Token
   *  EIP-20 compliant
   *  fork of https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol  commit fdf687c
   *  A transferrable token for use in authentifi audit campaign smart contracts
  */

  event Transfer(address indexed _from, address indexed _to, uint256 _value); // Token Transfer event
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);  // Approval of a credit transfer event

  // AuditorWallet is a struct for now in case of extended features
  struct AuditorWallet {
    uint tokensOwned;
  }
  uint256 constant private MAX_UINT256 = 2**256 - 1; // maximum credit allowance
  string public name; // name of the token
  string public symbol; // symbol for the token if listed
  uint public totalSupply; // total supply of tokens
  mapping(address => AuditorWallet) owners; // owners map of addresses to wallets
  mapping(address => mapping (address => uint256)) public allowed; // the credit mapping

  // initial constructor
  constructor(
    uint256 _initialAmount,  // the supply of authentifi tokens
    string _tokenName,  // the name of the token
    string _tokenSymbol //the symbol to be listed
  ) public {
    owners[msg.sender].tokensOwned = _initialAmount;
    totalSupply = _initialAmount;
    name = _tokenName;
    symbol = _tokenSymbol;
  }

  // Check the balance of tokens of an address
  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return owners[tokenOwner].tokensOwned;
  }

  // Transfer a number of tokens from the message sender's address to another address
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(owners[msg.sender].tokensOwned >= _value);
    owners[msg.sender].tokensOwned -= _value;
    owners[_to].tokensOwned += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  // Transfer from credit
  // Transfer using the message senders credit from the entered address to an address of the senders choosing
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    uint256 allowance = allowed[_from][msg.sender];
    require(owners[_from].tokensOwned >= _value && allowance >= _value);  //make sure the allowance and tokens in account are enough
    owners[_to].tokensOwned += _value;
    owners[_from].tokensOwned -= _value;
    if (allowance < MAX_UINT256) {  // this conditional prevents uint underflow
      allowed[_from][msg.sender] -= _value;
    }
    emit Transfer(_from, _to, _value);
    return true;
  }

  // Approve credit from senders account to a different spender address up to a certain amount
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  // Check the allowance of a spender in relation to a specific owner
  function allowance(address _owner, address _spender) public view returns (uint256 credit) {
    return allowed[_owner][_spender];
  }
}
