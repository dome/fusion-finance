require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments, network }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy, execute } = deployments;

    const { address: rewardAddress } = await deployments.get("RewardToken");
    const { address: baseAssetAddress } = await deployments.get("MockERC20");
    //const { address: feeManager } = await deployments.get("FeeManager");
    //const { address: wrapper } = await deployments.get("NativeWrapper");

    const f = await deploy("JdaiCore", {
      from: deployer,
      log: true,
      args: [baseAssetAddress,rewardAddress]
    });
    
    await execute(
      "RewardToken",
      { from: deployer, log: true },
      "transferOwnership",
      f.address
    );
    
  }
};
module.exports.tags = ["Core"];
module.exports.dependencies = ["MockERC20", "RewardToken"];
