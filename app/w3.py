from web3 import Web3

class W3:
    """Helper class to interact with chain."""
    def __init__(self, rpc_url: str):
        self.rpc_url = rpc_url
        self.w3 = Web3(Web3.HTTPProvider(self.rpc_url))
        assert self.w3.isConnected(), "Not connected to chain"  # todo remove assert

    def get_balance(self, address: str) -> float:
        """Get balance of address."""
        return self.w3.eth.get_balance(address)
