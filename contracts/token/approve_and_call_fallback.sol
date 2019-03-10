pragma solidity <0.4.24;

contract ApproveAndCallFallBack {
	function receiveApproval(address from, uint256 value, address token, bytes memory data) public;
}
