// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyTokenFactory is Ownable {
    address public recoveryAddress;

    // Declare three tokens
    EnergyToken public tokenE1;
    EnergyToken public tokenE2;
    EnergyToken public tokenE3;

    constructor(address _recoveryAddress) Ownable(msg.sender) {
        recoveryAddress = _recoveryAddress;

        // Deploy three EnergyTokens
        tokenE1 = new EnergyToken("Energy Token 1", "E1", recoveryAddress);
        tokenE2 = new EnergyToken("Energy Token 2", "E2", recoveryAddress);
        tokenE3 = new EnergyToken("Energy Token 3", "E3", recoveryAddress);
    }

    // Mint functions for each token
    function mintE1(address to, uint256 amount) public onlyOwner {
        tokenE1.mint(to, amount);
    }

    function mintE2(address to, uint256 amount) public onlyOwner {
        tokenE2.mint(to, amount);
    }

    function mintE3(address to, uint256 amount) public onlyOwner {
        tokenE3.mint(to, amount);
    }

    // Clawback functions for each token
    function clawbackE1(address from, uint256 amount) public onlyOwner {
        tokenE1.clawback(from, amount);
    }

    function clawbackE2(address from, uint256 amount) public onlyOwner {
        tokenE2.clawback(from, amount);
    }

    function clawbackE3(address from, uint256 amount) public onlyOwner {
        tokenE3.clawback(from, amount);
    }
}

// ERC-20 Token with Clawback Functionality
contract EnergyToken is ERC20, Ownable {
    address public recoveryAddress;

    constructor(string memory name, string memory symbol, address _recoveryAddress)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        recoveryAddress = _recoveryAddress;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function clawback(address from, uint256 amount) public onlyOwner {
        require(balanceOf(from) >= amount, "Insufficient balance to claw back");
        _transfer(from, recoveryAddress, amount);
    }
}
