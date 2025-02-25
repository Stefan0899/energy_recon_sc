// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePayment {
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

    struct EnergyBill {
        uint256 amountOwed; // Amount owed in ETH
        bool exists; // To check if bill is set
    }

    address public provider; // Provider1 (the contract deployer)

    mapping(address => EnergyOdometer) private userOdometers;
    mapping(address => EnergyUsage) private userUsage;
    mapping(address => EnergyBill) private energyBills;

    event BillGenerated(address indexed user, uint256 amount);
    event PaymentProcessed(address indexed user, uint256 amount, address indexed provider);

    constructor() {
        provider = msg.sender; // Provider1 is the deployer
    }

    modifier onlyProvider() {
        require(msg.sender == provider, "Only provider can update readings");
        _;
    }

    // Provider updates ODO readings and assigns a bill for a user
    function updateOdometersAndCalculateBill(
        address _user,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO
    ) public onlyProvider {
        EnergyOdometer storage prevOdo = userOdometers[_user];

        uint32 prevPeakODO = prevOdo.initialized ? prevOdo.peakODO : 0;
        uint32 prevStdODO = prevOdo.initialized ? prevOdo.stdODO : 0;
        uint32 prevOffODO = prevOdo.initialized ? prevOdo.offODO : 0;

        require(_newPeakODO >= prevPeakODO, "New PEAKODO must be greater than previous");
        require(_newStdODO >= prevStdODO, "New STDODO must be greater than previous");
        require(_newOffODO >= prevOffODO, "New OFFODO must be greater than previous");

        // Calculate usage
        uint32 peakUsage = _newPeakODO - prevPeakODO;
        uint32 stdUsage = _newStdODO - prevStdODO;
        uint32 offUsage = _newOffODO - prevOffODO;

        // Store new readings
        userOdometers[_user] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);
        userUsage[_user] = EnergyUsage(peakUsage, stdUsage, offUsage);

        // Calculate total bill
        uint256 totalPayment = ((uint256(peakUsage) * 2) + (uint256(stdUsage) * 1) + ((uint256(offUsage) * 5) / 10)) * 1e18;

        // Store the bill for this user
        energyBills[_user] = EnergyBill(totalPayment, true);
        emit BillGenerated(_user, totalPayment);
    }


    // User checks their usage
    function getUsage() public view returns (uint32, uint32, uint32) {
        EnergyUsage memory usage = userUsage[msg.sender];
        return (usage.peakUsage, usage.stdUsage, usage.offUsage);
    }

    // User checks their bill
    function getBillAmount() public view returns (uint256) {
        require(energyBills[msg.sender].exists, "No bill found for this user");
        return energyBills[msg.sender].amountOwed;
    }

    // User pays their bill, and the provider receives ETH
    function payBill() public payable {
        require(energyBills[msg.sender].exists, "No bill found for this user");
        uint256 amountOwed = energyBills[msg.sender].amountOwed;
        require(msg.value >= amountOwed, "Insufficient ETH sent");

        energyBills[msg.sender].exists = false; // Clear bill after payment
        payable(provider).transfer(amountOwed); // Transfer ETH to provider
        emit PaymentProcessed(msg.sender, amountOwed, provider);
    }
}
