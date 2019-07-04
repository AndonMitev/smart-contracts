// artifacts
var ConstantValidator = artifacts.require("./ConstantValidator.sol");

module.exports = function(deployer, network) {

  if (network.startsWith('mainnet') == true) return;

  deployer.deploy(ConstantValidator, true);

};
