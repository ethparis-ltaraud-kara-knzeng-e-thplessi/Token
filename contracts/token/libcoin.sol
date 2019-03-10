pragma solidity <0.4.24;

import "./erc20_interface.sol";
import "./approve_and_call_fallback.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract LibCoin is ERC20Interface, Ownable {
	using SafeMath for uint256;

	uint256 private constant MAX_UINT256 = 2**256 - 1;
	uint256 private constant INITIAL = 33 / 100 * MAX_UINT256;

	mapping (address => uint256) public balances;
	mapping (address => mapping (address => uint256)) public allowed;

	string public constant name = "LibCoin";
	string public constant symbol = "LIB";
	uint8 public constant decimals = 0;

	address public adder;

	constructor(address libContract) public {
		adder = libContract;
		balances[msg.sender] = INITIAL;
		totalSupply = INITIAL;
	}

	function balanceOf(address tokenOwner) public returns (uint balance) {
		return balances[tokenOwner];
	}

	function transfer(address to, uint value) public returns (bool success) {
		balances[msg.sender] = balances[msg.sender].sub(value);
		balances[to] = balances[to].add(value);
		emit Transfer(msg.sender, to, value);
		return true;
	}

	function transferFrom(address from, address to, uint256 value) public returns (bool success) {
		uint256 allowance = allowed[from][msg.sender];
		require(balances[from] >= value && allowance >= value);
		balances[to] += value;
		balances[from] -= value;
		if (allowance < MAX_UINT256) {
			allowed[from][msg.sender] -= value;
		}
		emit Transfer(from, to, value);
		return true;
	}

	function approve(address spender, uint tokens) public returns (bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}

	function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
		return allowed[tokenOwner][spender];
	}

	function approveAndCall(address spender, uint256 value, bytes memory data) public returns (bool success) {
		allowed[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		ApproveAndCallFallBack(spender).receiveApproval(msg.sender, value, address(this), data);
		return true;
	}

	function addTokens(uint256 value, address to) onlyOwner {
		balances[to].add(value);
		totalSupply.add(value);
		emit Added(to, value);
	}

	function () external payable {
		revert();
	}

	event Added(address to, uint256 value);
}
