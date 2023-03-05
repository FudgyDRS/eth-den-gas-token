import { ethers, network, run } from "hardhat";
import config from "../config";

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
    const GasToken = await ethers.getContractFactory("GasToken");
    const Vault = await ethers.getContractFactory("Vault");
    const Arbitrage = await ethers.getContractFactory("Arbitrage");
    const Treasury = await ethers.getContractFactory("Treasury");
    const Bank = await ethers.getContractFactory("Bank"); // after do GasToken.SetBank
    const LiquidationEngine = await ethers.getContractFactory("LiquidationEngine");
    
    // ------------------------------------------------------------------------
    // DEPLOYMENT
    const gasToken = await GasToken.deploy();
    await gasToken.deployed();
    console.log(`GasToken to ${gasToken.address}`);

    const vault = await Vault.deploy();
    await vault.deployed();
    console.log(`Vault to ${vault.address}`);

    const arbitrage = await Arbitrage.deploy();
    await arbitrage.deployed();
    console.log(`Arbitrage to ${arbitrage.address}`);

    const treasury = await Treasury.deploy();
    await treasury.deployed();
    console.log(`Treasury to ${treasury.address}`);

    const bank = await Bank.deploy(
      gasToken.address,
      vault.address,
      treasury.address
    );
    await bank.deployed();
    console.log(`Bank to ${bank.address}`);

    const liquidationEngine = await LiquidationEngine.deploy(
      gasToken.address,
      bank.address
    );
    await liquidationEngine.deployed();
    console.log(`LiquidationEngine to ${liquidationEngine.address}`);
    // ------------------------------------------------------------------------
    let tx = await gasToken.SetBank(bank.address);
    await tx.wait();

    // ------------------------------------------------------------------------
    // VEIRFICATION
    console.log(`Verifying smart contracts on...${networkName}:`);
    await run(`verify:verify`, {
      address: gasToken.address,
      constructorArguments: [],
    });
    await run(`verify:verify`, {
      address: vault.address,
      constructorArguments: [],
    });
    await run(`verify:verify`, {
      address: arbitrage.address,
      constructorArguments: [],
    });
    await run(`verify:verify`, {
      address: treasury.address,
      constructorArguments: [],
    });
    await run(`verify:verify`, {
      address: bank.address,
      constructorArguments: [
        gasToken.address,
        vault.address,
        treasury.address
      ]
    });
    await run(`verify:verify`, {
      address: liquidationEngine.address,
      constructorArguments: [
        gasToken.address,
        bank.address
      ]
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
