// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// Creating WETH for testing purposes
contract WETH is ERC20, Ownable {

    constructor() ERC20("WrappedEthereum", "WETh") {
        _mint(msg.sender, 5000 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

}





