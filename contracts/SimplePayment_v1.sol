// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimplePayment_v1 {
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

    struct DistributorEnergyUsage {
        uint32 dist_peakUsage;
        uint32 dist_stdUsage;
        uint32 dist_offUsage;
    }

    struct Distributor_User_Tariffs {
        uint32 peakTariff;
        uint32 standardTariff;
        uint32 offpeakTariff;
        uint32 basicTariff;
    }

    struct EnergyBill {
        uint256 amountOwed; // Amount owed in ETH
        bool exists; // To check if bill is set
    }

    mapping(address => bool) public providers; // List of approved providers
    mapping(address => EnergyOdometer) private userOdometers;
    mapping(address => EnergyUsage) private userUsage;
    mapping(address => DistributorEnergyUsage) public userDistributorUsage;
    mapping(address => Distributor_User_Tariffs) public userTariffs;
    mapping(address => EnergyBill) public distributorUsageBill;
    mapping(address => EnergyBill) private energyBills;
    mapping(address => uint256) public userE1Balances;
    mapping(address => uint256) public userE2Balances;
    mapping(address => uint256) public userE3Balances;

    event ProviderAdded(address indexed provider);
    event ProviderRemoved(address indexed provider);
    event BillGenerated(address indexed user, uint256 amount);
    event PaymentProcessed(address indexed user, uint256 amount, address indexed provider);

    address public owner; // Contract owner (can manage providers)

    constructor() {
        owner = msg.sender; // Contract deployer is the owner
        providers[msg.sender] = true; // The deployer is an initial provider
        emit ProviderAdded(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can manage providers");
        _;
    }

    modifier onlyProvider() {
        require(providers[msg.sender], "Only authorized providers can update readings");
        _;
    }

    // 🔹 Function: Add a new provider (Only owner can do this)
    function addProvider(address _provider) public onlyOwner {
        providers[_provider] = true;
        emit ProviderAdded(_provider);
    }

    // 🔹 Function: Remove a provider (Only owner can do this)
    function removeProvider(address _provider) public onlyOwner {
        providers[_provider] = false;
        emit ProviderRemoved(_provider);
    }

    function setUserTariffs(
        address _user,
        uint32 _peakTariff,
        uint32 _standardTariff,
        uint32 _offpeakTariff,
        uint32 _basicTariff
    ) public onlyProvider {
        userTariffs[_user] = Distributor_User_Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    // ✅ Helper function to fetch user's token balances
    function getTokenBalances(address _user, address e1Token, address e2Token, address e3Token) 
        internal view returns (uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens) 
    {
        IERC20 e1 = IERC20(e1Token);
        IERC20 e2 = IERC20(e2Token);
        IERC20 e3 = IERC20(e3Token);

        uint256 e1Balance = e1.balanceOf(_user);
        uint256 e2Balance = e2.balanceOf(_user);
        uint256 e3Balance = e3.balanceOf(_user);

        return (
            uint32(e1Balance / 1e18),
            uint32(e2Balance / 1e18),
            uint32(e3Balance / 1e18)
        );
    }

    function calculateDistributedUsage(
        uint32 peakUsage, uint32 stdUsage, uint32 offUsage,
        uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens
    ) internal pure returns (uint32, uint32, uint32) {
        uint32 dist_peakUsage = peakUsage;
        if (e1Tokens >= peakUsage) {
            dist_peakUsage = 0;
        } else {
            dist_peakUsage -= e1Tokens;
        }

        uint32 dist_stdUsage = stdUsage;
        if (e2Tokens >= stdUsage) {
            dist_stdUsage = 0;
        } else {
            dist_stdUsage -= e2Tokens;
        }

        uint32 dist_offUsage = offUsage;
        if (e3Tokens >= offUsage) {
            dist_offUsage = 0;
        } else {
            dist_offUsage -= e3Tokens;
        }

        return (dist_peakUsage, dist_stdUsage, dist_offUsage);
    }

    function calculateTotalBill(
        uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage,
        uint32 peakTariff, uint32 standardTariff, uint32 offpeakTariff, uint32 basicTariff
    ) internal pure returns (uint256) {
        return (
            (uint256(dist_peakUsage) * peakTariff) / 100 +
            (uint256(dist_stdUsage) * standardTariff) / 100 +
            (uint256(dist_offUsage) * offpeakTariff) / 100 +
            (basicTariff) / 100
        ) * 1e18;
    }

    function updateOdometersAndCalculateBill(
        address _user,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO,
        address _E1Token,
        address _E2Token,
        address _E3Token
    ) public onlyProvider {
        // ✅ Load structs directly in storage to reduce stack depth
        EnergyOdometer storage prevOdo = userOdometers[_user];
        Distributor_User_Tariffs storage tariffs = userTariffs[_user];

        // ✅ Validate ODO readings
        require(_newPeakODO >= prevOdo.peakODO, "New PEAKODO must be greater than previous");
        require(_newStdODO >= prevOdo.stdODO, "New STDODO must be greater than previous");
        require(_newOffODO >= prevOdo.offODO, "New OFFODO must be greater than previous");

        // ✅ Calculate total usage
        uint32 peakUsage = _newPeakODO - prevOdo.peakODO;
        uint32 stdUsage = _newStdODO - prevOdo.stdODO;
        uint32 offUsage = _newOffODO - prevOdo.offODO;

        // ✅ Fetch token balances in storage
        (uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens) = getTokenBalances(_user, _E1Token, _E2Token, _E3Token);

        // ✅ Calculate distributed energy usage
        (uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage) =
            calculateDistributedUsage(peakUsage, stdUsage, offUsage, e1Tokens, e2Tokens, e3Tokens);

        // ✅ Store updated readings in storage (instead of using new variables)
        prevOdo.peakODO = _newPeakODO;
        prevOdo.stdODO = _newStdODO;
        prevOdo.offODO = _newOffODO;
        prevOdo.initialized = true;

        userUsage[_user] = EnergyUsage(peakUsage, stdUsage, offUsage);
        userDistributorUsage[_user] = DistributorEnergyUsage(dist_peakUsage, dist_stdUsage, dist_offUsage);

        uint256 totalPayment = calculateTotalBill(
            dist_peakUsage, dist_stdUsage, dist_offUsage,
            tariffs.peakTariff, tariffs.standardTariff, tariffs.offpeakTariff, tariffs.basicTariff
        );

        // ✅ Store the bill correctly
        energyBills[_user] = EnergyBill(totalPayment, true);
        emit BillGenerated(_user, totalPayment);
    }

    // 🔹 Get current ODO readings
    function getOdometers(address _user) public view returns (uint32 peakODO, uint32 stdODO, uint32 offODO) {
        EnergyOdometer memory odo = userOdometers[_user];
        return (odo.peakODO, odo.stdODO, odo.offODO);
    }

    // 🔹 Get total energy usage stored
    function getUsage(address _user) public view returns (uint32 peakUsage, uint32 stdUsage, uint32 offUsage) {
        EnergyUsage memory usage = userUsage[_user];
        return (usage.peakUsage, usage.stdUsage, usage.offUsage);
    }

    // 🔹 Get distributor usage stored (after deducting tokens)
    function getDistributorUsage(address _user) public view returns (uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage) {
        DistributorEnergyUsage memory usage = userDistributorUsage[_user];
        return (usage.dist_peakUsage, usage.dist_stdUsage, usage.dist_offUsage);
    }

    function getTotalBill(address _user) public view returns (uint256) {
        EnergyBill memory bill = energyBills[_user]; // ✅ Fetch from the correct mapping
        return bill.exists ? bill.amountOwed : 0; // ✅ Returns the correct total bill
    }

    // 🔹 Get stored EOM token balances (E1, E2, and E3)
    function getEOMTokenBalance(address _user) public view returns (uint256 e1Balance, uint256 e2Balance, uint256 e3Balance) {
        return (userE1Balances[_user], userE2Balances[_user], userE3Balances[_user]);
    }

    function getUserTariffs(address _user) public view returns (uint32, uint32, uint32, uint32) {
        Distributor_User_Tariffs memory tariffs = userTariffs[_user];
        return (tariffs.peakTariff, tariffs.standardTariff, tariffs.offpeakTariff, tariffs.basicTariff);
    }

    // 🔹 Function: User pays their bill, ETH is sent to the provider
    function payBill(address _provider) public payable {
        require(energyBills[msg.sender].exists, "No bill found for this user");
        require(providers[_provider], "Invalid provider address");
        
        uint256 amountOwed = energyBills[msg.sender].amountOwed;
        require(msg.value >= amountOwed, "Insufficient ETH sent");

        energyBills[msg.sender].exists = false; // Clear bill after payment
        payable(_provider).transfer(amountOwed); // Transfer ETH to the provider
        emit PaymentProcessed(msg.sender, amountOwed, _provider);
    }
}
