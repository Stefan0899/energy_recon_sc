// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyTokenFactory is Ownable {
    address public recoveryAddress;

    // Declare three tokens
    EnergyToken public tokenEp;
    EnergyToken public tokenEs;
    EnergyToken public tokenEo;

    constructor(address _recoveryAddress) Ownable(msg.sender) {
        recoveryAddress = _recoveryAddress;

        // Deploy three EnergyTokens
        tokenEp = new EnergyToken("Peak Energy Token", "Ep", recoveryAddress);
        tokenEs = new EnergyToken("Std Energy Token", "Es", recoveryAddress);
        tokenEo = new EnergyToken("Off-peak Energy Token", "Eo", recoveryAddress);
    }

    // ✅ Separate function to whitelist this contract AFTER deployment
    function initializeWhitelist() public onlyOwner {
        tokenEp.addAllowedContract(address(this));
        tokenEs.addAllowedContract(address(this));
        tokenEo.addAllowedContract(address(this));
    }

    // ✅ Function to add another contract to the whitelist
    function addAuthorizedContract(address newContract) public onlyOwner {
        require(newContract.code.length > 0, "Not a contract"); // Ensures only contracts are added
        tokenEp.addAllowedContract(newContract);
        tokenEs.addAllowedContract(newContract);
        tokenEo.addAllowedContract(newContract);
    }

    // ✅ Function to remove a contract from the whitelist
    function removeAuthorizedContract(address contractAddress) public onlyOwner {
        tokenEp.removeAllowedContract(contractAddress);
        tokenEs.removeAllowedContract(contractAddress);
        tokenEo.removeAllowedContract(contractAddress);
    }

    // ✅ Mint functions (unchanged)
    function mintEp(address to, uint256 amount) public onlyOwner {
        tokenEp.mint(to, amount);
    }

    function mintEs(address to, uint256 amount) public onlyOwner {
        tokenEs.mint(to, amount);
    }

    function mintEo(address to, uint256 amount) public onlyOwner {
        tokenEo.mint(to, amount);
    }

    // ✅ Clawback functions now allow whitelisted contracts to call them
    function clawbackEp(address from, uint256 amount) public {
        tokenEp.clawback(from, amount);
    }

    function clawbackEs(address from, uint256 amount) public {
        tokenEs.clawback(from, amount);
    }

    function clawbackEo(address from, uint256 amount) public {
        tokenEo.clawback(from, amount);
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
