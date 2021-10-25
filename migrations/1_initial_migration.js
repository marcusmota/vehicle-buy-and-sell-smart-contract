const VehicleBuyAndSell = artifacts.require("VehicleBuyAndSell");

module.exports = function (deployer) {
  deployer.deploy(VehicleBuyAndSell);
};
