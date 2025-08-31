const { ethers, upgrades } = require("hardhat");
require("@openzeppelin/hardhat-upgrades");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying the contracts with the account:", deployer.address);

    // Deploy upgradeable proxy
    const BondingCurveToken = await ethers.getContractFactory("BondingCurveTokenUpgradeable");
    const bondingCurve = await upgrades.deployProxy(
        BondingCurveToken,
        [
            "CoinFantasy", // name
            "CF", // symbol
            ethers.parseUnits("500", 18), // initialSupply = 500 tokens
            ethers.parseEther("0.0001"), // basePrice in ETH
            ethers.parseEther("0.00001"), // slope
        ],
        { initializer: "initialize", kind: "uups" }
    );
    await bondingCurve.waitForDeployment();
    console.log("Bonding Curve Token deployed to:", await bondingCurve.getAddress());

    // // ---- Perform Buy ----
    // const buyTx = await bondingCurve.connect(deployer).buyTokens({
    //     value: ethers.parseEther("0.1"), // send 0.1 ETH to buy
    // });
    // await buyTx.wait();
    // console.log("Bought tokens with 0.1 ETH");

    // // Check balance after buy
    // const balanceAfterBuy = await bondingCurve.balanceOf(deployer.address);
    // console.log("Deployer token balance:", ethers.formatUnits(balanceAfterBuy, 18));

    // // ---- Perform Sell ----
    // const tokensToSell = ethers.parseUnits("5", 18); // Sell 10 tokens
    // const sellTx = await bondingCurve.connect(deployer).sellTokens(tokensToSell);
    // await sellTx.wait();
    // console.log("Sold 5 tokens back to contract");

    // // Check balance after sell
    // const balanceAfterSell = await bondingCurve.balanceOf(deployer.address);
    // console.log("Deployer token balance after sell:", ethers.formatUnits(balanceAfterSell, 18));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
