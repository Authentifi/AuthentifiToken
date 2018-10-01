var AuthentifiCampaign = artifacts.require("AuthentifiCampaign");
var AuthentifiAuditToken = artifacts.require("AuthentifiAuditToken")


module.exports = function(deployer) {
  deployer.deploy(AuthentifiAuditToken, 500, "AuthentifiAuditToken", "AAT" ).then(function() {
    deployer.deploy(AuthentifiCampaign, "Campaign", AuthentifiAuditToken.address, 10 );
  })

}
