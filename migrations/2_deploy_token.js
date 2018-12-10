var AuthentifiAuditToken = artifacts.require("AuthentifiAuditToken");
var AuthentifiCampaign = artifacts.require("AuthentifiCampaign");


module.exports = function(deployer) {
  return deployer.deploy(AuthentifiAuditToken, 500, "AuthentifiAuditToken", "AAT" ).then(function() {
    return deployer.deploy(AuthentifiCampaign, "Campaign", AuthentifiAuditToken.deployed().address, 10, 'safdsfads' );
  })
}
