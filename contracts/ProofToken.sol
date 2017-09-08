pragma solidity ^0.4.11;

import './SafeMath.sol';
import './ERC20.sol';
import './Ownable.sol';
import './ProofPresaleToken.sol';

/**
 * @title ProofToken (PRFT)
 * Standard Mintable ERC20 Token
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ProofToken is ERC20, Ownable {

  using SafeMath for uint256;

  ProofPresaleToken public presaleToken;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;
  mapping (address => bool) public claimed;


  string public constant name = "Proof Token";
  string public constant symbol = "PRFT";
  uint8 public constant decimals = 18;
  bool public mintingFinished = false;

  uint256 public constant TOKENS_ALLOCATED_TO_PROOF = 1181031 * (10 ** 18);

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  function ProofToken(address _presaleTokenAddress, address _proofWalletAddress) {

    presaleToken = ProofPresaleToken(_presaleTokenAddress);
    totalSupply = presaleToken.totalSupply();

    balances[_proofWalletAddress] = balances[_proofWalletAddress].add(TOKENS_ALLOCATED_TO_PROOF);
    totalSupply = totalSupply.add(TOKENS_ALLOCATED_TO_PROOF);
  }

  function() payable {
    revert();
  }

  function balanceOf(address _owner) constant returns (uint256) {
    return balances[_owner];
  }

  function transfer(address _to, uint _value) returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);

    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256) {
    return allowed[_owner][_spender];
  }

  function claim() returns (bool) {
    require(presaleToken.balanceOf(msg.sender) > 0);
    require(claimed[msg.sender] == false);

    claimed[msg.sender] = true;
    balances[msg.sender] = presaleToken.balanceOf(msg.sender);

    return true;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Mint(_to, _amount);
    return true;
  }

  /**
   * Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;

    MintFinished();
    return true;
  }
}