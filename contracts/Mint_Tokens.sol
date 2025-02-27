// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    // ✅ Separate function to whitelist this contract AFTER deployment
    function initializeWhitelist() public onlyOwner {
        tokenE1.addAllowedContract(address(this));
        tokenE2.addAllowedContract(address(this));
        tokenE3.addAllowedContract(address(this));
    }

    // ✅ Function to add another contract to the whitelist
    function addAuthorizedContract(address newContract) public onlyOwner {
        require(newContract.code.length > 0, "Not a contract"); // Ensures only contracts are added
        tokenE1.addAllowedContract(newContract);
        tokenE2.addAllowedContract(newContract);
        tokenE3.addAllowedContract(newContract);
    }

    // ✅ Function to remove a contract from the whitelist
    function removeAuthorizedContract(address contractAddress) public onlyOwner {
        tokenE1.removeAllowedContract(contractAddress);
        tokenE2.removeAllowedContract(contractAddress);
        tokenE3.removeAllowedContract(contractAddress);
    }

    // ✅ Mint functions (unchanged)
    function mintE1(address to, uint256 amount) public onlyOwner {
        tokenE1.mint(to, amount);
    }

    function mintE2(address to, uint256 amount) public onlyOwner {
        tokenE2.mint(to, amount);
    }

    function mintE3(address to, uint256 amount) public onlyOwner {
        tokenE3.mint(to, amount);
    }

    // ✅ Clawback functions now allow whitelisted contracts to call them
    function clawbackE1(address from, uint256 amount) public {
        tokenE1.clawback(from, amount);
    }

    function clawbackE2(address from, uint256 amount) public {
        tokenE2.clawback(from, amount);
    }

    function clawbackE3(address from, uint256 amount) public {
        tokenE3.clawback(from, amount);
    }
}

// ERC-20 Token with Clawback Functionality
contract EnergyToken is ERC20, Ownable {
    address public recoveryAddress;
    mapping(address => bool) public allowedContracts; // Whitelisted contracts

    constructor(string memory name, string memory symbol, address _recoveryAddress)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        recoveryAddress = _recoveryAddress;
    }

    // ✅ Function to mint tokens (unchanged)
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // ✅ Function to add an allowed contract (only contracts allowed)
    function addAllowedContract(address _contract) public onlyOwner {
        require(_contract.code.length > 0, "Not a contract"); // Prevents adding EOAs (user wallets)
        allowedContracts[_contract] = true;
    }

    // ✅ Function to remove an allowed contract
    function removeAllowedContract(address _contract) public onlyOwner {
        allowedContracts[_contract] = false;
    }

    // ✅ Clawback function only callable by whitelisted contracts
    function clawback(address from, uint256 amount) public {
        require(allowedContracts[msg.sender], "Unauthorized contract caller");
        require(balanceOf(from) >= amount, "Insufficient balance to claw back");
        _transfer(from, recoveryAddress, amount);
    }
}
