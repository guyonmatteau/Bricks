if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');
}

// connect wallet button
const ethereumButton = document.querySelector('.enableEthereumButton');
ethereumButton.addEventListener('click', () => {
  ethereum.enable();
  getCurrentAddress();

});

/*async function getAccount() {*/
  /*const accounts = await ethereum.request({ method: 'eth_requestAccounts' });*/
  /*const account = accounts[0];*/
  /*showAccount.innerHTML = account;*/
/*}*/

// mechanism to handle the reloading after account or chain changed
window.onload = function() {
    var reloading = sessionStorage.getItem("reloading");
    if (reloading) {
        sessionStorage.removeItem("reloading");
        getCurrentAddress();
    }
}

// handle changes in MetaMask
ethereum.on('accountsChanged', (address) => {
    sessionStorage.setItem("reloading", "true");
    document.location.reload();
});

ethereum.on('chainChanged', (_chainId) => {
    sessionStorage.setItem("reloading", "true");
    document.location.reload();
});

function getCurrentAddress()
{
    const currentAddress = ethereum.selectedAddress;
    const currentChain = ethereum.networkVersion;
    console.log("Current address: " + currentAddress);
    console.log("Current chain: " + currentChain);
    window.location = '/connect?address=' + currentAddress + '&chain=' + currentChain;


};


