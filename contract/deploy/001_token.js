require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments, network }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy, execute } = deployments;

    //const { address: jnft } = await deployments.get("JNFT");
    //const { address: feeManager } = await deployments.get("FeeManager");
    //const { address: wrapper } = await deployments.get("NativeWrapper");

    await deploy("MockERC20", {
      from: deployer,
      log: true,
      args: ["Mock Jdai", "JDAI"]
    });
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
module.exports.tags = ["MockERC20"];
// module.exports.dependencies = ["JNFT", "FeeManager", "NativeWrapper"];
