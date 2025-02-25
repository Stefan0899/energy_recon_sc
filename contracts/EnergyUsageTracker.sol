// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyUsageTracker {
    struct EnergyOdometer {
        uint32 peakODO;
        uint32 stdODO;
        uint32 offODO;
        bool initialized;  // Flag to check if this user has set ODO before
    }

    struct EnergyUsage {
        uint32 peakUsage;
        uint32 stdUsage;
        uint32 offUsage;
    }

    mapping(address => EnergyOdometer) private userOdometers;
    mapping(address => EnergyUsage) private userUsage;

    function updateOdometers(uint32 _newPeakODO, uint32 _newStdODO, uint32 _newOffODO) public {
        EnergyOdometer storage prevOdo = userOdometers[msg.sender];

        // If this is the user's first ODO update, just store values
        if (!prevOdo.initialized) {
            userOdometers[msg.sender] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);
            return;
        }

        // Ensure new readings are greater than previous ones
        require(_newPeakODO >= prevOdo.peakODO, "New PEAKODO must be greater than previous");
        require(_newStdODO >= prevOdo.stdODO, "New STDODO must be greater than previous");
        require(_newOffODO >= prevOdo.offODO, "New OFFODO must be greater than previous");

        // Calculate usage
        uint32 peakUsage = _newPeakODO - prevOdo.peakODO;
        uint32 stdUsage = _newStdODO - prevOdo.stdODO;
        uint32 offUsage = _newOffODO - prevOdo.offODO;

        // Store new readings
        userOdometers[msg.sender] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);
        
        // Store usage
        userUsage[msg.sender] = EnergyUsage(peakUsage, stdUsage, offUsage);
    }

    function getOdometers() public view returns (uint32, uint32, uint32) {
        EnergyOdometer memory odo = userOdometers[msg.sender];
        return (odo.peakODO, odo.stdODO, odo.offODO);
    }

    function getUsage() public view returns (uint32, uint32, uint32) {
        EnergyUsage memory usage = userUsage[msg.sender];
        return (usage.peakUsage, usage.stdUsage, usage.offUsage);
    }
}

