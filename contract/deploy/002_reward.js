require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments, network }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy, execute } = deployments;

    //const { address: jnft } = await deployments.get("JNFT");
    //const { address: feeManager } = await deployments.get("FeeManager");
    //const { address: wrapper } = await deployments.get("NativeWrapper");

    const f = await deploy("RewardToken", {
      from: deployer,
      log: true,
      });
    console.log(f.address);
    /*
    await execute(
      "JAuction",
      { from: deployer, log: true },
      "setNativeWrapper",
      wrapper
    );
    */
  }
};
module.exports.tags = ["RewardToken"];
// module.exports.dependencies = ["JNFT", "FeeManager", "NativeWrapper"];
