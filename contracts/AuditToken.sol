pragma solidity ^0.4.21;

contract AuthentifiAuditToken {

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  struct AuditorWallet {
    uint tokensOwned;
  }
  uint256 constant private MAX_UINT256 = 2**256 - 1;
  string public name;
  string public symbol;
  uint public totalSupply;
  mapping(address => AuditorWallet) owners;
  mapping (address => mapping (address => uint256)) public allowed;

  constructor(
    uint256 _initialAmount,
    string _tokenName,
    string _tokenSymbol
  ) public {
    owners[msg.sender].tokensOwned = _initialAmount;
    totalSupply = _initialAmount;
    name = _tokenName;
    symbol = _tokenSymbol;
  }

  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return owners[tokenOwner].tokensOwned;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(owners[msg.sender].tokensOwned >= _value);
    owners[msg.sender].tokensOwned -= _value;
    owners[_to].tokensOwned += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    uint256 allowance = allowed[_from][msg.sender];
    require(owners[_from].tokensOwned >= _value && allowance >= _value);
    owners[_to].tokensOwned += _value;
    owners[_from].tokensOwned -= _value;
    if (allowance < MAX_UINT256) {
      allowed[_from][msg.sender] -= _value;
    }
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
