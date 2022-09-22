require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments, network }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy, execute } = deployments;

    //const { address: rewardAddress } = await deployments.get("RewardToken");
    //const { address: baseAssetAddress } = await deployments.get("MockERC20");
    //const { address: feeManager } = await deployments.get("FeeManager");
    //const { address: wrapper } = await deployments.get("NativeWrapper");

    const f = await deploy("JdaiStaking2", {
      from: deployer,
      log: true,
    });

    
  }
};
module.exports.tags = ["JdaiStaking2"];

