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
| Goerli | [address](link) | _version_ |

## Deployment

The contracts are developed and deployed with Forge and Alchemy. In order to deploy the contract(s), an `.env` file is required that contains the following envvars
```
ALCHEMY_KEY=<alchemy-api-key>
PRIVATE_KEY_GOERLI=<private-key-of-goerli-address-to-deploy-from>
```

## MVPs

For iterative development the following versions have been iterated over:
1. Contract that keeps track of users funds and is allowed to transfer funds on behalf of user. 
2. Contract that able to swap WETH to USDC.  
    * Contract that is able to swaps ether to USDC on a fixed rate on behalf of user (so no borrowing).  
    * Add Chainlink reference contract to request current ETH/USDC rate. 
3. Ability to borrow against ETH, with default value.
4. 
