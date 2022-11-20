import os

from web3 import Web3

from app.abi import ERC20


class Chain:
    """Helper class to interact with EOA's or contracts on chain."""

    CHAIN_MAPPING = {
        "1": "https://eth-mainnet.g.alchemy.com/v2/",
        "5": "https://eth-goerli.alchemyapi.io/v2/",
        "31337": "http://localhost:8548",  # hardhat
    }

    API_KEY_MAPPING = {
        "1": os.getenv("ALCHEMY_KEY_MAIN"),
        "5": os.getenv("ALCHEMY_KEY_GOERLI"),
        "31337": "",  # no key required
    }

    def __init__(self, chain_id: str):
        self.chain_id = str(chain_id)
        self.rpc_url = self.CHAIN_MAPPING[self.chain_id]
        rpc_url_with_key = f"{self.rpc_url}{self.API_KEY_MAPPING[self.chain_id]}"
        self.w3 = Web3(Web3.HTTPProvider(rpc_url_with_key))
        if not self.w3.isConnected():
            print("WARNING: Not connected to chain {self.chain_id}")

    def get_balance(self, address: str) -> float:
        """Get balance of address in ETH."""
        checksum_address = self._address_to_checksum(address)
        return self._wei_to_eth(self.w3.eth.get_balance(checksum_address))

    def get_balance_of(self, address) -> float:
        """Call method 'balanceOf' on the contract."""
        return 1.0

    @staticmethod
    def _address_to_checksum(address: str) -> str:
        """Convert lowercase to Checksummed address."""
        # this is not safe but fine for now
        return Web3.toChecksumAddress(address)

    @staticmethod
    def _wei_to_eth(value) -> float:
        return value * 1e-18
