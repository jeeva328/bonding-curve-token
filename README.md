# Bonding Curve Token (Upgradeable)

An ERC-20 token with linear bonding curve pricing mechanism where token price increases with supply.

## Prerequisites
- Node.js v22.19.0
- Metamask wallet
- Testnet ETH for deployment

## Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
Create `.env` file:
```bash
PRIVATE_KEY=your_private_key
INFURA_API_KEY=your_infura_key  
ETHERSCAN_API_KEY=your_etherscan_key
```

## Development Commands

### Compile Contract
```bash
npx hardhat compile
```

### Run Tests
```bash
npx hardhat test
```

### Deploy to Local Network
```bash
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

### Deploy to Testnet (Bsc)
```bash
npx hardhat run scripts/deploy.js --network bscTestnet
```

### Verify Contract on Binance Smart Chain Testnet
```bash
npx hardhat verify --network bscTestnet DEPLOYED_CONTRACT_ADDRESS
```

## Key Features
- Linear bonding curve pricing: `price = basePrice + (slope × totalSupply)`
- Buy tokens with ETH, sell tokens for ETH
- Upgradeable using UUPS proxy pattern
- Owner can update curve parameters and withdraw ETH
- Reentrancy protection and access controls

## Contract Functions
- `buyTokens()` - Purchase tokens with ETH
- `sellTokens(amount)` - Sell tokens back for ETH  
- `price()` - Get current token price
- `updateCurveParams()` - Owner only: update pricing
- `withdrawETH()` - Owner only: withdraw contract ETH
