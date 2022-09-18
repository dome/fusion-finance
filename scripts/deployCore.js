const { ethers, network } = require("hardhat");

const main = async () => {
  let baseAssetAddress;
  let aggregatorAddress;

  if (network.name === "hardhat") {
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    let baseAsset = await MockERC20.deploy("Mock Asset", "MOCK");
    baseAssetAddress = baseAsset.address;
    aggregatorAddress = "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e";
    console.log(`Base asset mock address: ${baseAssetAddress}`);
    console.log(`Chainlink price aggregator address: ${aggregatorAddress}`);
  } else if (network.name === "goerli") {
    baseAssetAddress = "0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844";
    aggregatorAddress = "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e";
    console.log(`Base asset address: ${baseAssetAddress}`);
    console.log(`Chainlink price aggregator address: ${aggregatorAddress}`);
  } else if (network.name === "arbitrum") {
    baseAssetAddress = "";
    aggregatorAddress = "0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612";
    console.log(`Base asset address: ${baseAssetAddress}`);
    console.log(`Chainlink price aggregator address: ${aggregatorAddress}`);
  }

  const FusionToken = await ethers.getContractFactory("FusionToken");
  const fusionToken = await FusionToken.deploy();
  console.log(
    `Fusion Token  address: ${fusionToken.address}, deployer: ${fusionToken.signer.address}`
  );

  const FusionCore = await ethers.getContractFactory("FusionCore");
  const fusionCore = await FusionCore.deploy(
    baseAssetAddress,
    fusionToken.address,
    aggregatorAddress
  );
  console.log(
    `Fusion Core address: ${fusionCore.address}, deployer: ${fusionCore.signer.address}`
  );

  await fusionToken.transferOwnership(fusionCore.address);
  console.log(
    `Fusion Token ownership transferred from ${fusionToken.signer.address} to ${fusionCore.address}`
  );
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
