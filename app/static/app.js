let provider;
let accounts;

let accountAddress = "";
let signer;

if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');
}

const ethereumButton = document.querySelector('.enableEthereumButton');
const showAccount = document.querySelector('.showAccount');
const showChain = document.querySelector('.showChain');

ethereumButton.addEventListener('click', () => {
  ethereum.enable();
  connectWallet();
});

async function getAccount() {
  const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
  const account = accounts[0];
  showAccount.innerHTML = account;
}

ethereum.on('chainChanged', (chainId) => {
  // Handle the new chain.
  // Correctly handling chain changes can be complicated.
  // We recommend reloading the page unless you have good reason not to.
  console.log("New chain: " + chainId);
  connectWallet();
  //window.location.reload();
});



function connectWallet() {
    //ethereum.enable().then(function () {

        const chain = ethereum.networkVersion;
        showChain.innerHTML = chain;
        const address = ethereum.selectedAddress;
        showAccount.innerHTML = address


        /*provider = new ethers.providers.Web3Provider(web3.currentProvider);*/


        /*provider.getNetwork().then(function (result) {*/
            /*console.log(result);*/
            /*if (result['chainId'] != 1) {*/
                /*document.getElementById("msg").textContent = 'Switch to Mainnet!';*/

            /*} else { // okay, confirmed we're on mainnet*/

                /*provider.listAccounts().then(function (result) {*/
                    /*console.log(result);*/
                    /*accountAddress = result[0]; // figure out the user's Eth address*/

                    /*provider.getBalance(String(result[0])).then(function (balance) {*/
                        /*var myBalance = (balance / ethers.constants.WeiPerEther).toFixed(4);*/
                        /*console.log("Your Balance: " + myBalance);*/
                        /*document.getElementById("msg").textContent = 'ETH Balance: ' + myBalance;*/
                    /*});*/

                    /*// get a signer object so we can do things that need signing*/
                    /*signer = provider.getSigner();*/

                    /*// build out the table of players*/
                /*})*/
            /*}*/
        /*})*/
    //})
};


/*web3.eth.getAccounts()*/
        /*.then((response) => {*/
            /*const publicAddressResponse = response[0];*/
            /*console.log(publicAddressResponse);*/

            /*if (!(typeof publicAddressResponse === "undefined")) {*/
                /*setPublicAddress(publicAddressResponse);*/
                /*getNonce(publicAddressResponse);*/
            /*}*/
        /*})*/
        /*.catch((e) => {*/
            /*console.error(e);*/
/*        }*/
