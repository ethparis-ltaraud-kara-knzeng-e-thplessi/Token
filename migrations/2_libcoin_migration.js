const Libcoin = artifacts.require("token/libcoin");

module.exports = function(deployer) {
	deployer.deploy(Libcoin).then(() => {
		deployer.deploy(Book_Lib, Libcoin.address)
	});
};
