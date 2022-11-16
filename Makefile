.PHONY: chain deploy test lint clean
include .env
export 

### GLOBALS
CONTRACT=Scheduler
DOCKER_IMAGE=Scheduler

## NETWORKS
GOERLI_RPC_URL=https://eth-goerli.alchemyapi.io/v2/
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/
MAINNET_BLOCK=15974812
LOCALHOST_RPC_URL=http://localhost:8548

# PROTOCOL
chain:
	npx hardhat node --verbose

accounts: 
	npx hardhat run --network localhost scripts/accounts.js

deploy.localhost: 
	forge create --private-key ${PRIVATE_KEY1} src/${CONTRACT}.sol:${CONTRACT}

deploy.goerli:
	forge create --private-key ${PRIVATE_KEY_GOERLI} --rpc-url ${GOERLI_RPC_URL}${ALCHEMY_KEY} --verify src/${CONTRACT}.sol:${CONTRACT}

test:
	forge test -vvvv --fork-url ${MAINNET_RPC_URL}${ALCHEMY_KEY} 

console:
	npx hardhat console --network localhost

lint:
	forge fmt 

clean:
	-rm -r build cache

# UI
ui:
	streamlit run app/main.py
