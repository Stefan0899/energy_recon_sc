// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract SimplePayment_v1_o_up {
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

    // 🔹 Define the Distributor struct with tariffs mapped by ID
    struct Distributor {
        bool isRegistered;
        mapping(uint256 => Distributor_User_Tariffs) tariffs; // Tariffs mapped by ID
    }

    // ✅ Transmittor Struct (Similar to Distributor)
    struct Transmittor {
        bool isRegistered;
        mapping(uint256 => Distributor_User_Tariffs) tariffs;
    }

    //Generator
    struct Generator {
        bool isRegistered;
        mapping(uint256 => Distributor_User_Tariffs) tariffs;
    }

    // ✅ Mapping for Distributors & Transmittors
    mapping(address => Distributor) public distributors;
    mapping(address => Transmittor) public transmittors;
    mapping(address => Generator) public generators;

    // ✅ Permissions
    mapping(address => bool) public providers; 
    mapping(address => bool) public transmittorsRegistered;
    mapping(address => bool) public generatorsRegistered;

    // ✅ Assign Tariffs to Users
    mapping(address => uint256) public userTariffID;
    mapping(address => address) public userDistributor;

    mapping(address => uint256) public userTransmittorTariffID;
    mapping(address => address) public userTransmittor;

    mapping(address => uint256) public userGeneratorTariffID;
    mapping(address => address) public userGenerator;

    mapping(address => EnergyOdometer) private userOdometers;
    mapping(address => EnergyUsage) private userUsage;
    mapping(address => DistributorEnergyUsage) public userDistributorUsage;
    mapping(address => EnergyBill) public userBills; 
    mapping(address => EnergyBill) private energyBills;
    mapping(address => uint256) public userE1Balances;
    mapping(address => uint256) public userE2Balances;
    mapping(address => uint256) public userE3Balances;

    event ProviderAdded(address indexed provider);
    event ProviderRemoved(address indexed provider);
    event BillGenerated(address indexed user, uint256 amount);
    event PaymentProcessed(address indexed user, uint256 amount, address indexed provider);
    event DistributorAdded(address indexed distributor);
    event DistributorRemoved(address indexed distributor);
    event TransmittorAdded(address indexed transmittor);
    event TransmittorRemoved(address indexed transmittor);
    event GeneratorAdded(address indexed transmittor);
    event GeneratorRemoved(address indexed transmittor);

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

    // 🔹 Modifier: Restrict access to only registered distributors
    modifier onlyDistributor() {
        require(distributors[msg.sender].isRegistered, "Only registered distributors can perform this action");
        _;
    }

    modifier onlyTransmittor() {
        require(transmittors[msg.sender].isRegistered, "Only registered transmittors can perform this action");
        _;
    }

    modifier onlyGenerator() {
        require(generators[msg.sender].isRegistered, "Only registered transmittors can perform this action");
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

    // 🔹 Function: Add a new distributor (Only owner can do this)
    function addDistributor(address _distributor) public onlyOwner {
        require(!distributors[_distributor].isRegistered, "Distributor already registered");
        distributors[_distributor].isRegistered = true;
        emit DistributorAdded(_distributor);
    }

    // 🔹 Function: Remove a distributor (Only owner can do this)
    function removeDistributor(address _distributor) public onlyOwner {
        require(distributors[_distributor].isRegistered, "Distributor not registered");
        distributors[_distributor].isRegistered = false; // ✅ Correct: Mark as unregistered
        emit DistributorRemoved(_distributor);
    }

    // ✅ Manage Transmittors
    function addTransmittor(address _transmittor) public onlyOwner {
        require(!transmittors[_transmittor].isRegistered, "Transmittor already registered");
        transmittors[_transmittor].isRegistered = true; // ✅ Ensure this is added!
        emit TransmittorAdded(_transmittor);
    }

    function removeTransmittor(address _transmittor) public onlyOwner {
        require(transmittors[_transmittor].isRegistered, "Transmittor not registered");
        transmittors[_transmittor].isRegistered = false;
        emit TransmittorRemoved(_transmittor);
    }

        // ✅ Manage Transmittors
    function addGenerator(address _generator) public onlyOwner {
        require(!generators[_generator].isRegistered, "Transmittor already registered");
        generators[_generator].isRegistered = true; // ✅ Ensure this is added!
        emit GeneratorAdded(_generator);
    }

    function removeGenerator(address _generator) public onlyOwner {
        require(generators[_generator].isRegistered, "Transmittor not registered");
        generators[_generator].isRegistered = false;
        emit GeneratorRemoved(_generator);
    }


    // ✅ Distributor Tariff Management
    function setTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyDistributor {
        distributors[msg.sender].tariffs[_tariffID] = Distributor_User_Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    function assignTariffToUser(address _user, uint256 _tariffID) public onlyDistributor {
        userTariffID[_user] = _tariffID;
        userDistributor[_user] = msg.sender;
    }

    // ✅ Transmittor Tariff Management
    function setTransmittorTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyTransmittor {
        transmittors[msg.sender].tariffs[_tariffID] = Distributor_User_Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    function assignTransmittorTariffToUser(address _user, uint256 _tariffID) public onlyTransmittor {
        userTransmittorTariffID[_user] = _tariffID;
        userTransmittor[_user] = msg.sender;
    }

    // ✅ Generator Tariff Management
    function setGeneratorTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyGenerator {
        generators[msg.sender].tariffs[_tariffID] = Distributor_User_Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    function assignGeneratorTariffToUser(address _user, uint256 _tariffID) public onlyGenerator {
        userGeneratorTariffID[_user] = _tariffID;
        userGenerator[_user] = msg.sender;
    }

    // ✅ Fetch user's token balances
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

    // ✅ Calculate & Store Total Usage
    function calculateTotalUsage(
        address _user,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO
    ) public {
        EnergyOdometer storage prevOdo = userOdometers[_user]; // Get stored ODO values

        // ✅ Set previous ODOs to 1 if they are not initialized
        uint32 prevPeakODO = prevOdo.initialized ? prevOdo.peakODO : 0;
        uint32 prevStdODO = prevOdo.initialized ? prevOdo.stdODO : 0;
        uint32 prevOffODO = prevOdo.initialized ? prevOdo.offODO : 0;

        require(_newPeakODO >= prevPeakODO, "New PEAKODO must be greater than previous");
        require(_newStdODO >= prevStdODO, "New STDODO must be greater than previous");
        require(_newOffODO >= prevOffODO, "New OFFODO must be greater than previous");

        // ✅ Calculate total usage
        uint32 peakUsage = _newPeakODO - prevPeakODO;
        uint32 stdUsage = _newStdODO - prevStdODO;
        uint32 offUsage = _newOffODO - prevOffODO;

        // ✅ Store new ODO values
        userOdometers[_user] = EnergyOdometer(_newPeakODO, _newStdODO, _newOffODO, true);

        // ✅ Store calculated usage
        userUsage[_user] = EnergyUsage(peakUsage, stdUsage, offUsage);
    }

    function calculateDistributorUsage(
        uint32 peakUsage, uint32 stdUsage, uint32 offUsage,
        uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens
    ) internal pure returns (uint32, uint32, uint32) {
        return (
            e1Tokens >= peakUsage ? 0 : peakUsage - e1Tokens,
            e2Tokens >= stdUsage ? 0 : stdUsage - e2Tokens,
            e3Tokens >= offUsage ? 0 : offUsage - e3Tokens
        );
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

    function calculateDistributionFee(
        uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens,
        uint32 trans_peakTariff, uint32 trans_standardTariff, uint32 trans_offpeakTariff,
        uint32 dist_peakTariff, uint32 dist_standardTariff, uint32 dist_offpeakTariff
    ) internal pure returns (uint256) {
        // ✅ Ensure that Distributor tariffs are not greater than Transmittor tariffs
        require(dist_peakTariff >= trans_peakTariff, "Distributor Peak Tariff must exceed Transmittor Peak Tariff");
        require(dist_standardTariff >= trans_standardTariff, "Distributor Standard Tariff must exceed Transmittor Standard Tariff");
        require(dist_offpeakTariff >= trans_offpeakTariff, "Distributor Off-Peak Tariff must exceed Transmittor Off-Peak Tariff");

        uint256 peakFee;
        uint256 standardFee;
        uint256 offpeakFee;

        // ✅ Convert everything to uint256 before doing math
        uint256 peakTariffDiff = uint256(dist_peakTariff) - uint256(trans_peakTariff);
        uint256 standardTariffDiff = uint256(dist_standardTariff) - uint256(trans_standardTariff);
        uint256 offpeakTariffDiff = uint256(dist_offpeakTariff) - uint256(trans_offpeakTariff);

        uint256 e1 = uint256(e1Tokens);
        uint256 e2 = uint256(e2Tokens);
        uint256 e3 = uint256(e3Tokens);

        // ✅ Cap energy tokens to prevent excessive multiplication
        require(e1 <= 1e6 && e2 <= 1e6 && e3 <= 1e6, "Token balances too large"); 

        // ✅ Use `unchecked` to prevent overflow reverts when safe
        unchecked {
            peakFee = (peakTariffDiff * e1 * 100)/100;
            standardFee = (standardTariffDiff * e2 *100)/100;
            offpeakFee = (offpeakTariffDiff * e3 *100)/100;
        }

        // ✅ Perform division before multiplying by `1e18` to prevent large numbers
        uint256 totalFee = (peakFee + standardFee + offpeakFee);
    
        return (totalFee * 1e16); // ✅ Safe conversion to ETH format
    }

    function calculateTransmissionFee(
        uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens,
        uint32 trans_peakTariff, uint32 trans_standardTariff, uint32 trans_offpeakTariff,
        uint32 gen_peakTariff, uint32 gen_standardTariff, uint32 gen_offpeakTariff
    ) internal pure returns (uint256) {
        // ✅ Ensure that Distributor tariffs are not greater than Transmittor tariffs
        require(trans_peakTariff >= gen_peakTariff, "Transmission Peak Tariff must exceed Generator Peak Tariff");
        require(trans_standardTariff >= gen_standardTariff, "Transmission Standard Tariff must exceed Generator Standard Tariff");
        require(trans_offpeakTariff >= gen_offpeakTariff, "Transmission Off-Peak Tariff must exceed Generator Off-Peak Tariff");

        uint256 peakFee;
        uint256 standardFee;
        uint256 offpeakFee;

        // ✅ Convert everything to uint256 before doing math
        uint256 peakTariffDiff = uint256(trans_peakTariff) - uint256(gen_peakTariff);
        uint256 standardTariffDiff = uint256(trans_standardTariff) - uint256(gen_standardTariff);
        uint256 offpeakTariffDiff = uint256(trans_offpeakTariff) - uint256(gen_offpeakTariff);

        uint256 e1 = uint256(e1Tokens);
        uint256 e2 = uint256(e2Tokens);
        uint256 e3 = uint256(e3Tokens);

        // ✅ Cap energy tokens to prevent excessive multiplication
        require(e1 <= 1e6 && e2 <= 1e6 && e3 <= 1e6, "Token balances too large"); 

        // ✅ Use `unchecked` to prevent overflow reverts when safe
        unchecked {
            peakFee = (peakTariffDiff * e1)/100;
            standardFee = (standardTariffDiff * e2)/100;
            offpeakFee = (offpeakTariffDiff * e3)/100;
        }

        // ✅ Perform division before multiplying by `1e18` to prevent large numbers
        uint256 totalFee = (peakFee + standardFee + offpeakFee);
    
        return (totalFee * 1e18); // ✅ Safe conversion to ETH format
    }

    // ✅ Provider assigns a bill based on stored total usage
    function updateOdometersAndCalculateBill(
        address _user,
        address _E1Token,
        address _E2Token,
        address _E3Token,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO,
        address _distributor
    ) public onlyProvider {

        // ✅ Fetch assigned tariff ID
        uint256 tariffID = userTariffID[_user];

        // ✅ Fetch the tariff from the distributor's book
        Distributor_User_Tariffs memory tariffs = distributors[_distributor].tariffs[tariffID];

        require(tariffs.peakTariff > 0, "Tariff not set for this user under distributor");

        //calculateTotalUsage
        calculateTotalUsage(_user, _newPeakODO, _newStdODO, _newOffODO);

        // ✅ Fetch total usage from storage (already calculated in calculateTotalUsage)
        EnergyUsage memory usage = userUsage[_user];

        // ✅ Fetch token balances
        (uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens) = getTokenBalances(_user, _E1Token, _E2Token, _E3Token);

        // ✅ Store the user's token balances
        userE1Balances[_user] = e1Tokens;
        userE2Balances[_user] = e2Tokens;
        userE3Balances[_user] = e3Tokens;

        // ✅ Calculate distributor energy usage (subtracting token balances)
        (uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage) = calculateDistributorUsage(
            usage.peakUsage, usage.stdUsage, usage.offUsage, e1Tokens, e2Tokens, e3Tokens
        );

        // ✅ Store calculated distributor usage
        userDistributorUsage[_user] = DistributorEnergyUsage(dist_peakUsage, dist_stdUsage, dist_offUsage);

        uint256 totalPayment = calculateTotalBill(
            dist_peakUsage, 
            dist_stdUsage, 
            dist_offUsage, 
            tariffs.peakTariff, 
            tariffs.standardTariff, 
            tariffs.offpeakTariff, 
            tariffs.basicTariff
        );

        // ✅ Store the bill in the correct mapping
        energyBills[_user] = EnergyBill(totalPayment, true);
        emit BillGenerated(_user, totalPayment);
    }

    // ✅ Provider assigns a bill based on stored total usage
    function eomRecon(
        address _user,
        address _E1Token,
        address _E2Token,
        address _E3Token,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO,
        address _distributor
    ) public onlyProvider {

        //calculateTotalUsage, and updates storage on usage and ODO
        calculateTotalUsage(_user, _newPeakODO, _newStdODO, _newOffODO);

        // ✅ Fetch token balances
        (uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens) = getTokenBalances(_user, _E1Token, _E2Token, _E3Token);

        // ✅ Store the user's token balances
        userE1Balances[_user] = e1Tokens;
        userE2Balances[_user] = e2Tokens;
        userE3Balances[_user] = e3Tokens;

        // ✅ Calculate distributor energy usage (subtracting token balances)
        (uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage) = calculateDistributorUsage(
            usage.peakUsage, usage.stdUsage, usage.offUsage, e1Tokens, e2Tokens, e3Tokens
        );

        // ✅ Store calculated distributor usage
        userDistributorUsage[_user] = DistributorEnergyUsage(dist_peakUsage, dist_stdUsage, dist_offUsage);

        // ✅ Store the bill in the correct mapping
        energyBills[_user] = EnergyBill(totalPayment, true);
        emit BillGenerated(_user, totalPayment);
    }

    function getTransmissionFee(address _user) public view returns (uint256 energyFee, uint256 distributionFee, uint256 transmissionFee) {
        require(userTariffID[_user] > 0, "No distributor tariff assigned to this user");
        require(userTransmittorTariffID[_user] > 0, "No transmittor tariff assigned to this user");
        require(userGeneratorTariffID[_user] > 0, "No generator tariff assigned to this user");

        address distributorAddress = userDistributor[_user];
        address transmittorAddress = userTransmittor[_user];
        address generatorAddress = userGenerator[_user];

        require(distributors[distributorAddress].isRegistered, "Distributor is not registered");
        require(transmittors[transmittorAddress].isRegistered, "Transmittor is not registered");
        require(generators[generatorAddress].isRegistered, "Generator is not registered");

        uint256 distributorTariffID = userTariffID[_user];
        uint256 transmittorTariffID = userTransmittorTariffID[_user];
        uint256 generatorTariffID = userGeneratorTariffID[_user];

        Distributor_User_Tariffs memory distributorTariff = distributors[distributorAddress].tariffs[distributorTariffID];
        Distributor_User_Tariffs memory transmittorTariff = transmittors[transmittorAddress].tariffs[transmittorTariffID];
        Distributor_User_Tariffs memory generatorTariff = generators[generatorAddress].tariffs[generatorTariffID];

        // ✅ Fetch energy token balances (instead of total energy usage)
        uint32 e1Balance = uint32(userE1Balances[_user]);
        uint32 e2Balance = uint32(userE2Balances[_user]);
        uint32 e3Balance = uint32(userE3Balances[_user]);

        // ✅ Fetch total energy usage for transmission fee calculation
        EnergyUsage memory totalUsage = userUsage[_user];

        // ✅ Calculate distributor energy usage (subtracting token balances)
        (uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage) = calculateDistributorUsage(
            totalUsage.peakUsage, totalUsage.stdUsage, totalUsage.offUsage, e1Balance, e2Balance, e3Balance
        );

        energyFee = calculateDistributionFee(
            dist_peakUsage, dist_stdUsage, dist_offUsage,  
            0, 0, 0,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff
        );

        distributionFee = calculateDistributionFee(
            e1Balance, e2Balance, e3Balance,  
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff
        );

        transmissionFee = calculateDistributionFee(
            totalUsage.peakUsage, totalUsage.stdUsage, totalUsage.offUsage,  
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff,
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff
        );

        return (energyFee, distributionFee, transmissionFee);
    }


    function getDistributionFee(address _user) public view returns (uint256 totalFee) {
        require(userTariffID[_user] > 0, "No distributor tariff assigned to this user");
        require(userTransmittorTariffID[_user] > 0, "No transmittor tariff assigned to this user");

        address distributorAddress = userDistributor[_user];
        address transmittorAddress = userTransmittor[_user];

        require(distributors[distributorAddress].isRegistered, "Distributor is not registered");
        require(transmittors[transmittorAddress].isRegistered, "Transmittor is not registered");

        uint256 distributorTariffID = userTariffID[_user];
        uint256 transmittorTariffID = userTransmittorTariffID[_user];

        Distributor_User_Tariffs memory distributorTariff = distributors[distributorAddress].tariffs[distributorTariffID];
        Distributor_User_Tariffs memory transmittorTariff = transmittors[transmittorAddress].tariffs[transmittorTariffID];

        // ✅ Fetch energy token balances (instead of total energy usage)
        uint32 e1Balance = uint32(userE1Balances[_user]);
        uint32 e2Balance = uint32(userE2Balances[_user]);
        uint32 e3Balance = uint32(userE3Balances[_user]);

        return calculateDistributionFee(
            e1Balance, e2Balance, e3Balance,  // ✅ Use energy token balances
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff
        );
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

    function getUserTariffs(address _user) public view returns (uint32, uint32, uint32, uint32, address, uint256) {
        // ✅ Ensure the user has been assigned a tariff
        require(userTariffID[_user] > 0, "No tariff assigned to this user");

        // ✅ Ensure the user has an assigned distributor
        require(userDistributor[_user] != address(0), "No distributor assigned to this user");
        address distributorAddress = userDistributor[_user];

        // ✅ Ensure the distributor exists
        require(distributors[distributorAddress].isRegistered, "Distributor is not registered");

        // ✅ Fetch assigned tariff ID
        uint256 tariffID = userTariffID[_user];

        // ✅ Fetch tariff details from distributor's tariff book
        Distributor storage distributor = distributors[distributorAddress];
        Distributor_User_Tariffs memory tariffs = distributor.tariffs[tariffID];

        require(tariffs.peakTariff > 0, "Tariff ID not found under distributor");

        return (
            tariffs.peakTariff,
            tariffs.standardTariff,
            tariffs.offpeakTariff,
            tariffs.basicTariff,
            distributorAddress, // ✅ Return distributor address
            tariffID // ✅ Return assigned tariff ID
        );
    }

    function getUserTransmittorTariffs(address _user) public view returns (uint32, uint32, uint32, uint32, address, uint256) {
        require(userTransmittorTariffID[_user] > 0, "No transmittor tariff assigned to this user");
        require(userTransmittor[_user] != address(0), "No transmittor assigned to this user");

        address transmittorAddress = userTransmittor[_user];
        uint256 tariffID = userTransmittorTariffID[_user];

        require(transmittors[transmittorAddress].isRegistered, "Transmittor is not registered");

        Distributor_User_Tariffs memory tariffs = transmittors[transmittorAddress].tariffs[tariffID];
        require(tariffs.peakTariff > 0, "Tariff ID not found under transmittor");

        return (
            tariffs.peakTariff,
            tariffs.standardTariff,
            tariffs.offpeakTariff,
            tariffs.basicTariff,
            transmittorAddress, // ✅ Return transmittor address
            tariffID // ✅ Return assigned tariff ID
        );
    }

    function getUserGeneratorTariffs(address _user) public view returns (uint32, uint32, uint32, uint32, address, uint256) {
        require(userGeneratorTariffID[_user] > 0, "No generator tariff assigned to this user");
        require(userGenerator[_user] != address(0), "No generator assigned to this user");

        address generatorAddress = userGenerator[_user];
        uint256 tariffID = userGeneratorTariffID[_user];

        require(generators[generatorAddress].isRegistered, "Generator is not registered");

        Distributor_User_Tariffs memory tariffs = generators[generatorAddress].tariffs[tariffID];
        require(tariffs.peakTariff > 0, "Tariff ID not found under transmittor");

        return (
            tariffs.peakTariff,
            tariffs.standardTariff,
            tariffs.offpeakTariff,
            tariffs.basicTariff,
            generatorAddress, // ✅ Return transmittor address
            tariffID // ✅ Return assigned tariff ID
        );
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
