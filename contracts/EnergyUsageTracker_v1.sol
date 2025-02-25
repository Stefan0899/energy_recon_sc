// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyUsageTracker {
    struct EnergyOdometer {
        uint32 peakODO;
        uint32 stdODO;
        uint32 offODO;
        bool initialized;
    }

    struct EnergyUsage {
        uint32 peakUsage;
        uint32 stdUsage;
        uint32 offUsage;
    }

    address public owner;

    // Mapping to store allowed users and their password hashes
    mapping(address => bytes32) private authorizedUsers;
    mapping(address => EnergyOdometer) private userOdometers;
    mapping(address => EnergyUsage) private userUsage;

    // 🔹 Modifier to allow only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 🔹 Modifier to allow only authorized users with correct password
    modifier onlyAuthorized(string memory password) {
        require(authorizedUsers[msg.sender] != 0x0, "Not an authorized user");
        require(keccak256(abi.encodePacked(password)) == authorizedUsers[msg.sender], "Incorrect password");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 🔹 Function: Add a user with a hashed password (Owner only)
    function addAuthorizedUser(address user, string memory password) public onlyOwner {
        authorizedUsers[user] = keccak256(abi.encodePacked(password));
    }

    // 🔹 Function: Remove a user (Owner only)
    function removeAuthorizedUser(address user) public onlyOwner {
        delete authorizedUsers[user];
    }

    // 🔹 Function: Update Odometers (User must provide correct password)
    function updateOdometers(string memory password, uint32 _newPeakODO, uint32 _newStdODO, uint32 _newOffODO) public onlyAuthorized(password) {
        EnergyOdometer storage prevOdo = userOdometers[msg.sender];

        if (!prevOdo.initialized) {
            userOdometers[msg.sender] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);
            return;
        }

        require(_newPeakODO >= prevOdo.peakODO, "New PEAKODO must be greater than previous");
        require(_newStdODO >= prevOdo.stdODO, "New STDODO must be greater than previous");
        require(_newOffODO >= prevOdo.offODO, "New OFFODO must be greater than previous");

        uint32 peakUsage = _newPeakODO - prevOdo.peakODO;
        uint32 stdUsage = _newStdODO - prevOdo.stdODO;
        uint32 offUsage = _newOffODO - prevOdo.offODO;

        userOdometers[msg.sender] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);
        userUsage[msg.sender] = EnergyUsage(peakUsage, stdUsage, offUsage);
    }

    // 🔹 Function: Get Odometer Readings
    function getOdometers() public view returns (uint32, uint32, uint32) {
        EnergyOdometer memory odo = userOdometers[msg.sender];
        return (odo.peakODO, odo.stdODO, odo.offODO);
    }

    // 🔹 Function: Get Energy Usage
    function getUsage() public view returns (uint32, uint32, uint32) {
        EnergyUsage memory usage = userUsage[msg.sender];
        return (usage.peakUsage, usage.stdUsage, usage.offUsage);
    }
}
