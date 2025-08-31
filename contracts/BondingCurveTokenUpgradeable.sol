// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract BondingCurveTokenUpgradeable is
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    uint256 public basePrice; // The minimum price for one token in wei 
    uint256 public slope; // The rate at which token price increases per token minted
    uint256 public initialSupplyAtLaunch; // The initial token supply minted to deployer when contract is launched

    event BuyExecuted(
        address indexed buyer,
        uint256 ethAmount,
        uint256 tokensReceived
    );
    event SellExecuted(
        address indexed seller,
        uint256 tokenAmount,
        uint256 ethReceived
    );
    event CurveParamsUpdated(uint256 newBasePrice, uint256 newSlope);
    event ETHWithdrawn(address indexed recipient, uint256 ethAmount);

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _basePrice,
        uint256 _slope
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        require(_initialSupply > 0, "Initial supply should be > 0");
        basePrice = _basePrice;
        slope = _slope;
        initialSupplyAtLaunch = _initialSupply;

        _mint(_msgSender(), _initialSupply);
    }

    /**
     * @notice Get the current price of one token in wei
     * @dev Price increases linearly with total supply using formula: basePrice + (slope × totalSupply)
     * @return Current token price in wei (ETH)
     */
    function price() public view returns (uint256) {
        return basePrice + ((slope * totalSupply()) / 1e18);
    }

    /**
     * @notice Buy tokens by sending ETH to the contract
     * @dev Calculates token amount based on current price and mints tokens to buyer
     * Requirements:
     * - Must send ETH with transaction
     * - ETH amount must be sufficient to buy at least some tokens
     */
    function buyTokens() external payable nonReentrant {
        require(msg.value > 0, "Token Buy: ETH amount should not be zero");

        uint256 tokenPrice = price();
        require(tokenPrice > 0, "Token Buy: Invalid token price");

        uint256 tokenAmountToMint = (msg.value * 1e18) / tokenPrice;
        require(
            tokenAmountToMint > 0,
            "Token Buy: Insufficient ETH to buy tokens"
        );

        _mint(_msgSender(), tokenAmountToMint);

        emit BuyExecuted(_msgSender(), msg.value, tokenAmountToMint);
    }

    /**
     * @notice Sell your tokens back to the contract for ETH
     * @dev Burns tokens and transfers ETH at current market price
     * @param tokenAmount Amount of tokens to sell (in wei, 18 decimals)
     * Requirements:
     * - Must own enough tokens to sell
     * - Cannot sell more tokens than total supply
     * - Contract must have enough ETH to pay out
     */
    function sellTokens(uint256 tokenAmount) external nonReentrant {
        require(tokenAmount > 0, "Token Sell: Invalid token amount provided");
        require(
            balanceOf(_msgSender()) >= tokenAmount,
            "Token Sell: Insufficient tokens to sell"
        );
        require(
            totalSupply() > tokenAmount,
            "Token Sell: Cannot sell more than total supply"
        );

        uint256 ethAmount = (price() * tokenAmount) / 1e18;

        require(
            address(this).balance >= ethAmount,
            "Token Sell: Insufficient ETH balance in contract"
        );

        _burn(_msgSender(), tokenAmount);
        payable(_msgSender()).transfer(ethAmount);

        emit SellExecuted(_msgSender(), tokenAmount, ethAmount);
    }

    /**
     * @notice Update the bonding curve pricing parameters (Owner only)
     * @dev Changes the base price and slope that determine token pricing
     * @param _basePrice New minimum token price in wei
     * @param _slope New price increase rate per token in wei
     * Requirements:
     * - Only contract owner can call this
     * - Both parameters must be greater than zero
     */
    function updateCurveParams(
        uint256 _basePrice,
        uint256 _slope
    ) external onlyOwner {
        require(_basePrice > 0, "Base price must be greater than 0");
        require(_slope > 0, "Slope must be greater than 0");

        basePrice = _basePrice;
        slope = _slope;

        emit CurveParamsUpdated(_basePrice, _slope);
    }

    /**
     * @notice Withdraw all ETH from the contract (Owner only)
     * @dev Transfers the entire ETH balance to specified recipient
     * @param recipient Address to receive the withdrawn ETH
     * Requirements:
     * - Only contract owner can call this
     * - Recipient address must be valid
     * - Contract must have ETH balance to withdraw
     */
    function withdrawETH(
        address payable recipient
    ) external onlyOwner nonReentrant {
        require(recipient != address(0), "Invalid recipient");

        uint256 ethBalance = address(this).balance;
        require(ethBalance > 0, "Insufficient balance");

        (bool success, ) = recipient.call{value: ethBalance}("");
        require(success, "ETH Transfer failed");

        emit ETHWithdrawn(recipient, ethBalance);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    receive() external payable {}
}
