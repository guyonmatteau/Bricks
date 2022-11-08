# Bricks
Capstone project for Artemis bootcamp. 

## Introduction
Bricks is a combination of Defi and paying your rent or mortgage. The basic idea is that it is a combination of e.g. Aave or Gearbox, and a scheduler that allows you to set recurring payments to an EOA. The protocol consists of the following components:

- Scheduler contract: allowing a user to submit a certain recurring (e.g. monthly) transaction;
    - contract should make use of chainlink oracle to fetch latest price of asset to see how much
    it needs to convert to e.g. USDC.
- Vault contract, that contains the deposits of a user; or (V2)
    - contract that acts as intermediary between Aave and and the Scheduler contract.
- Borrow contract, that allows a user to set a certain amount to borrow.
- Notifier: that checks if a certain transaction is executed or not
- Frontend: that allows a user to interact with the contracts

## Contract addresses

| Network | Address | Version |
| Goerli | [<address>](link) | <version> |

## Deployment

The contracts are developed and deployed with Forge and Alchemy. In order to deploy the contract(s), an `.env` file is required that contains the following envvars
```
ALCHEMY_KEY=<alchemy-api-key>
PRIVATE_KEY_GOERLI=<private-key-of-goerli-address-to-deploy-from>
```

## MVPs

For iterative development the following versions have been iterated over:
1a. One ownable ERC20 contract (Scheduler), where the contract swaps ether to USDC (so no borrowing)
1b. Integrate it with Chainlink (1a)
2. Ability to borrow against ETH, with default value
3. 
