// scripts/accounts.js
// MetaMask injects a Web3 Provider as "web3.currentProvider", so
// we can wrap it up in the ethers.js Web3Provider, which wraps a
// Web3 Provider and exposes the ethers.js Provider API.
// This function detects most providers injected at window.ethereum

/*const {detectEthereumProvider} = require('@metamask/detect-provider');*/

/*const provider = await detectEthereumProvider();*/

/*if (provider) {*/
  /*// From now on, this should always be true:*/
  /*// provider === window.ethereum*/
  /*console.log(provider);*/
/*} else {*/
  /*console.log('Please install MetaMask!');*/
/*}*/

const provider = window.ethereum;
console.log(provider);
