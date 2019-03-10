pragma solidity <0.4.24;

import "../token/libcoin.sol";

contract BookLibrary {
	struct Pos {
		int32 lat;
		int32 lon;
		uint16 rad;
	}

	address public libTokenContract;

	mapping (address => Pos) public sellers;
	mapping (uint48 => address[]) public offers;
	mapping (address => mapping (address => mapping (uint48 => uint256))) public pendings;

	constructor(address libToken) {
		libTokenContract = libToken;
	}

	function sellBook(uint48 isbn) {
		require(sellers[msg.sender].rad != 0);
		require(isbn <= 9999999999 || (isbn >= 9780000000000 && isbn <= 9799999999999));
		offers[isbn].push(msg.sender);
		emit NewOffer(sellers[msg.sender].lat, sellers[msg.sender].lon, sellers[msg.sender].rad, msg.sender, isbn);
	}

	function sellBook(uint48 isbn, int32 lat, int32 lon, uint16 rad) {
		require(lat <= 18000000);
		require(lat >= -18000000);
		require(lon <= 18000000);
		require(lon >= -18000000);
		require(rad > 0);
		sellers[msg.sender].lat = lat;
		sellers[msg.sender].lon = lon;
		sellers[msg.sender].rad = rad;
		sellBook(isbn);
	}

	function splitBytes(bytes memory byteSource) private pure returns (address addr, uint48 isbn) {
		bytes20 byteAddr;
		bytes6 byteIsbn;

		uint j = 0;
		for (uint i = 0; i < 20; i++) {
			byteAddr[i] = byteSource[j];
			j++;
		}
		for (uint i = 0; i < 6; i++) {
			byteIsbn[i] = byteSource[j];
			j++;
		}
		assembly {
			addr := mload(add(byteAddr,20))
			isbn := mload(add(byteisbn,6))
		}
		return (addr, isbn);
	}

	function receiveApproval(address from, uint256 value, address token, bytes memory data) {
		uint sellerInd;
		address to;
		uint48 isbn;

		require(token == libTokenContract);
		(to, isbn) = splitBytes(data);
		for (uint i = 0; i < offers[isbn].length; i++) {
			if (offers[isbn][i] == to) {
				sellerInd = i;
			}
		}
		require(offers[isbn][sellerInd] == to);
		delete offers[isbn][sellerInd];
		pendings[to][from][isbn] = value;
	}

	function validate(address seller, address buyer, uint48 isbn) {
		LibCoin libCoin = LibCoin(LibCoinAddress);
		uint256 value;

		value = pendings[seller][buyer][isbn];
		delete pendings[seller][buyer][isbn];
		libCoin.transfer(seller, value);
	}

	event NewOffer(int32 lat, int32 lon, uint16 rad, address seller, uint48 isbn);
}
