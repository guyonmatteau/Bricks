// script to deploy contract to network
async function main() {
    // We get the contract to deploy
    const SharedWallet = await ethers.getContractFactory("SharedWallet");
    console.log("Deploying SharedWallet...");

    // here comment the owner you want to set. In next ieration
    // can be refactored to automatically setting them from hardhat run --arg commands
    const goerliOwners = ["0xD534Be138B332910269eedf3574E1BF88f6803c2"];
    const localOwners = [
        "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    ];
    const sharedwallet = await SharedWallet.deploy(goerliOwners, 1);
    await sharedwallet.deployed();
    console.log("SharedWallet deployed to:", sharedwallet.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
