import { ethers, network, run } from "hardhat";

const main = async () => {
  // Get network data from Hardhat config (see hardhat.config.ts).
  const networkName = network.name;

  // Check if the network is supported.

  if (
    networkName === "bscTestnet" || 
    networkName === "sepoliaTestnet" ||
    networkName === "scrollTestnet" ||
    networkName === "mantleTestnet" ||
    networkName === "mumbaiTestnet" ||
    networkName === "neonTestnet"
    ) {
    console.log(`Deploying to ${networkName} network...`);


    // Compile contracts.
    await run("compile");
    console.log("Compiled contracts...");

    /**
     * Deploy order:
     * GasToken
     * Vault
     * Arbitrage
     * Bank
     * LiquidationEngine
     */

    // Deploy contracts.
    console.log(`Deploying smart contracts to...${networkName}:`);
    const Derivadata = await ethers.getContractFactory("Derivadata");
    
    // ------------------------------------------------------------------------
    // DEPLOYMENT
    const derivadata = await Derivadata.deploy();
    await derivadata.deployed();
    console.log(`Derivadata to ${derivadata.address}`);

    // ------------------------------------------------------------------------
    // VEIRFICATION
    console.log(`Verifying smart contracts on...${networkName}:`);
    await run(`verify:verify`, {
      address: derivadata.address,
      constructorArguments: [],
    });
    // ------------------------------------------------------------------------
  } else {
    console.log(`Deploying to ${networkName} network is not supported...`);
  }
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
