var AuthentifiAuditToken = artifacts.require("AuthentifiAuditToken")


module.exports = function(deployer) {
  deployer.deploy(AuthentifiAuditToken, 500, "AuthentifiAuditToken", "AAT" );
}
