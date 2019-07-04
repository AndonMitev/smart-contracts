// artifacts
var SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('mainnet') == true) return;

  deployer.deploy(SimpleToken);

};
