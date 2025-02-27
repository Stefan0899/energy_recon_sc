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

    struct Tariffs {
        uint32 peakTariff;
        uint32 standardTariff;
        uint32 offpeakTariff;
        uint32 basicTariff;
    }
    struct Fees {
        uint256 energyFee;
        uint256 distributionFee;
        uint256 transmissionFee;
        uint256 providerFee;
        uint256 totalBill;
    }
    // 🔹 Define the Distributor struct with tariffs mapped by ID
    struct Distributor {
        bool isRegistered;
        mapping(uint256 => Tariffs) tariffs; // Tariffs mapped by ID
    }

    // ✅ Transmittor Struct (Similar to Distributor)
    struct Transmittor {
        bool isRegistered;
        mapping(uint256 => Tariffs) tariffs;
    }

    //Generator
    struct Generator {
        bool isRegistered;
        mapping(uint256 => Tariffs) tariffs;
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
    // Mapping to store the assigned provider for each user
    mapping(address => address) public userProvider; // Maps users to providers
    
    mapping(address => uint256) public userTariffID;
    mapping(address => address) public userDistributor;

    mapping(address => uint256) public userTransmittorTariffID;
    mapping(address => address) public userTransmittor;

    mapping(address => uint256) public userGeneratorTariffID;
    mapping(address => address) public userGenerator;

    // ✅ Mapping to store end-of-month token balances
    mapping(address => EnergyUsage) public endOfMonthBalances;
    mapping(address => EnergyUsage) private userUsage;
    mapping(address => EnergyUsage) public userDistributorUsage;
    mapping(address => EnergyOdometer) private userOdometers;

    // ✅ Mapping to store user fees
    mapping(address => Fees) public userFees;

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
    event PaymentProcessed(address indexed user);

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

    //Assign provider to user
    function assignProviderToUser(address _user) public onlyProvider {
        require(userProvider[_user] == address(0), "User already has a provider"); // Prevent reassignment
        userProvider[_user] = msg.sender; // Assign the calling provider to the user
    }

        // ✅ Assign Distributor to User
    function assignDistributorToUser(address _user) public onlyDistributor {
        require(userDistributor[_user] == address(0), "User already has a distributor"); // Prevent reassignment
        userDistributor[_user] = msg.sender; // Assign the calling distributor to the user
    }

    // ✅ Assign Transmittor to User
    function assignTransmittorToUser(address _user) public onlyTransmittor {
        require(userTransmittor[_user] == address(0), "User already has a transmittor"); // Prevent reassignment
        userTransmittor[_user] = msg.sender; // Assign the calling transmittor to the user
    }

    // ✅ Assign Generator to User
    function assignGeneratorToUser(address _user) public onlyGenerator {
        require(userGenerator[_user] == address(0), "User already has a generator"); // Prevent reassignment
        userGenerator[_user] = msg.sender; // Assign the calling generator to the user
    }

    // ✅ Distributor Tariff Management
    function setTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyDistributor {
        distributors[msg.sender].tariffs[_tariffID] = Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    function assignTariffToUser(address _user, uint256 _tariffID) public onlyDistributor {
        userTariffID[_user] = _tariffID;
        userDistributor[_user] = msg.sender;
    }

    // ✅ Transmittor Tariff Management
    function setTransmittorTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyTransmittor {
        transmittors[msg.sender].tariffs[_tariffID] = Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
    }

    function assignTransmittorTariffToUser(address _user, uint256 _tariffID) public onlyTransmittor {
        userTransmittorTariffID[_user] = _tariffID;
        userTransmittor[_user] = msg.sender;
    }

    // ✅ Generator Tariff Management
    function setGeneratorTariff(uint256 _tariffID, uint32 _peakTariff, uint32 _standardTariff, uint32 _offpeakTariff, uint32 _basicTariff) public onlyGenerator {
        generators[msg.sender].tariffs[_tariffID] = Tariffs(_peakTariff, _standardTariff, _offpeakTariff, _basicTariff);
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

    function calculateAndStoreDistributorUsage(
        address _user,
        address _E1Token,
        address _E2Token,
        address _E3Token
    ) internal {
        // ✅ Fetch total energy usage from storage
        EnergyUsage memory usage = userUsage[_user];

        // ✅ Fetch token balances
        (uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens) = getTokenBalances(_user, _E1Token, _E2Token, _E3Token);

        // ✅ Store the balances in `endOfMonthBalances`
        endOfMonthBalances[_user] = EnergyUsage(e1Tokens, e2Tokens, e3Tokens);

        // ✅ Calculate distributor energy usage (subtracting token balances)
        uint32 dist_peakUsage = e1Tokens >= usage.peakUsage ? 0 : usage.peakUsage - e1Tokens;
        uint32 dist_stdUsage = e2Tokens >= usage.stdUsage ? 0 : usage.stdUsage - e2Tokens;
        uint32 dist_offUsage = e3Tokens >= usage.offUsage ? 0 : usage.offUsage - e3Tokens;

        // ✅ Store calculated distributor usage
        userDistributorUsage[_user] = EnergyUsage(dist_peakUsage, dist_stdUsage, dist_offUsage);
    }

    function calculateFees(
        uint32 e1Tokens, uint32 e2Tokens, uint32 e3Tokens,
        uint32 upstream_peakTariff, uint32 upstream_standardTariff, uint32 upstream_offpeakTariff,
        uint32 downstream_peakTariff, uint32 downstream_standardTariff, uint32 downstream_offpeakTariff
    ) internal pure returns (uint256) {
        // ✅ Ensure that Distributor tariffs are not greater than Transmittor tariffs
        require(downstream_peakTariff >= upstream_peakTariff, "Downstream Peak Tariff must exceed Upstream Peak Tariff");
        require(downstream_standardTariff >= upstream_standardTariff, "Downstream Standard Tariff must exceed Upstream Standard Tariff");
        require(downstream_offpeakTariff >= upstream_offpeakTariff, "Downstream Off-Peak Tariff must exceed Upstream Off-Peak Tariff");

        uint256 peakFee;
        uint256 standardFee;
        uint256 offpeakFee;

        // ✅ Convert everything to uint256 before doing math
        uint256 peakTariffDiff = uint256(downstream_peakTariff) - uint256(upstream_peakTariff);
        uint256 standardTariffDiff = uint256(downstream_standardTariff) - uint256(upstream_standardTariff);
        uint256 offpeakTariffDiff = uint256(downstream_offpeakTariff) - uint256(upstream_offpeakTariff);

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

    // ✅ Provider assigns a bill based on stored total usage
    function eomRecon(
        address _user,
        address _E1Token,
        address _E2Token,
        address _E3Token,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO
    ) public onlyProvider {
        //Stakeholders registered

        //Tariffs set

        //Calculate Total Usage, Updates storgae of TotalUsage and ODOS
        calculateTotalUsage(_user, _newPeakODO, _newStdODO, _newOffODO);

        //Calculate Distributor Usage, Updates storage on distributor usage and EOM token balances
        calculateAndStoreDistributorUsage(_user, _E1Token, _E2Token, _E3Token);

        //Calculate Energy fee, distribution fee, and transmission fee, and store these values
        storeFees(_user);
    }

    function storeFees(address _user) internal {
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

        Tariffs memory distributorTariff = distributors[distributorAddress].tariffs[distributorTariffID];
        Tariffs memory transmittorTariff = transmittors[transmittorAddress].tariffs[transmittorTariffID];
        Tariffs memory generatorTariff = generators[generatorAddress].tariffs[generatorTariffID];

        //✅ Fetch stored end-of-month token balances like `userUsage[_user]`
        EnergyUsage memory eomBalances = endOfMonthBalances[_user];
        EnergyUsage memory totalUsage = userUsage[_user];
        EnergyUsage memory distUsage = userDistributorUsage[_user];

        uint256 energyFee = calculateFees(
            distUsage.peakUsage, distUsage.stdUsage, distUsage.offUsage,  
            0, 0, 0,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff
        );

        uint256 distributionFee = calculateFees(
            eomBalances.peakUsage, eomBalances.stdUsage, eomBalances.offUsage,  
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff
        );

        uint256 transmissionFee = calculateFees(
            totalUsage.peakUsage, totalUsage.stdUsage, totalUsage.offUsage,  
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff,
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff
        );

        // ✅ Calculate `providerFee` as 0.5% of the total fee amount
        uint256 providerFee = ((energyFee + distributionFee + transmissionFee) *5 )/ 1000; // 0.5% of total fees
        
        //Total bill
        uint256 totalBill = energyFee + distributionFee + transmissionFee + providerFee;

        userFees[_user] = Fees(energyFee, distributionFee, transmissionFee, providerFee, totalBill);
    }

    function viewAllUserData(address _user) 
        public 
        view 
        returns (
            uint32 peakUsage, uint32 stdUsage, uint32 offUsage,  // Total Usage
            uint32 dist_peakUsage, uint32 dist_stdUsage, uint32 dist_offUsage, // Distributor Usage
            uint32 e1Balance, uint32 e2Balance, uint32 e3Balance, // Token Balances
            uint256 energyFee, uint256 distributionFee, uint256 transmissionFee, uint256 providerFee, uint256 totalBill, // Fees
            uint32 distributorPeakTariff, uint32 distributorStandardTariff, uint32 distributorOffpeakTariff, uint32 distributorBasicTariff, // Distributor Tariffs
            uint32 transmittorPeakTariff, uint32 transmittorStandardTariff, uint32 transmittorOffpeakTariff, uint32 transmittorBasicTariff, // Transmittor Tariffs
            uint32 generatorPeakTariff, uint32 generatorStandardTariff, uint32 generatorOffpeakTariff, uint32 generatorBasicTariff // Generator Tariffs
        ) 
    {
        // ✅ Fetch stored Total Energy Usage
        EnergyUsage memory totalUsage = userUsage[_user];

        // ✅ Fetch stored Distributor Energy Usage
        EnergyUsage memory distUsage = userDistributorUsage[_user];

        // ✅ Fetch stored End-of-Month Token Balances
        EnergyUsage memory eomBalances = endOfMonthBalances[_user];

        // ✅ Fetch stored Fees
        Fees memory fees = userFees[_user];

        // ✅ Fetch assigned Distributor, Transmittor, and Generator addresses
        address distributorAddress = userDistributor[_user];
        address transmittorAddress = userTransmittor[_user];
        address generatorAddress = userGenerator[_user];

        // ✅ Fetch assigned Tariff IDs
        uint256 distributorTariffID = userTariffID[_user];
        uint256 transmittorTariffID = userTransmittorTariffID[_user];
        uint256 generatorTariffID = userGeneratorTariffID[_user];

        // ✅ Fetch stored tariffs
        Tariffs memory distributorTariff = distributors[distributorAddress].tariffs[distributorTariffID];
        Tariffs memory transmittorTariff = transmittors[transmittorAddress].tariffs[transmittorTariffID];
        Tariffs memory generatorTariff = generators[generatorAddress].tariffs[generatorTariffID];

        return (
            totalUsage.peakUsage, totalUsage.stdUsage, totalUsage.offUsage, // Total Usage
            distUsage.peakUsage, distUsage.stdUsage, distUsage.offUsage, // Distributor Usage
            eomBalances.peakUsage, eomBalances.stdUsage, eomBalances.offUsage, // Token Balances
            fees.energyFee, fees.distributionFee, fees.transmissionFee, fees.providerFee, fees.totalBill, // Fees
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff, distributorTariff.basicTariff, // Distributor Tariffs
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff, transmittorTariff.basicTariff, // Transmittor Tariffs
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff, generatorTariff.basicTariff // Generator Tariffs
        );
    }

    function payEnergyFees() public payable {
        require(userProvider[msg.sender] != address(0), "No provider assigned to this user");
        require(userDistributor[msg.sender] != address(0), "No distributor assigned to this user");
        require(userTransmittor[msg.sender] != address(0), "No transmittor assigned to this user");

        address payable provider = payable(userProvider[msg.sender]);
        address payable distributor = payable(userDistributor[msg.sender]);
        address payable transmittor = payable(userTransmittor[msg.sender]);

        Fees memory userFee = userFees[msg.sender];

        require(userFee.totalBill > 0, "No outstanding bill for this user");

        uint256 energyAndDistributionFee = ((userFee.energyFee + userFee.distributionFee));
        uint256 transmissionFee = (userFee.transmissionFee);
        uint256 providerFee = (userFee.providerFee);
        uint256 totalBillETH = (userFee.totalBill);

        console.log("Expected Total Bill (wei):", totalBillETH);
        console.log("Energy + Distribution Fee (wei):", energyAndDistributionFee);
        console.log("Transmission Fee (wei):", transmissionFee);
        console.log("Provider Fee (wei):", providerFee);
        console.log("msg.value (wei):", msg.value);

        require(msg.value >= totalBillETH, "Insufficient ETH sent");

        // ✅ Perform transfers
        distributor.transfer(energyAndDistributionFee);
        transmittor.transfer(transmissionFee);
        provider.transfer(providerFee);

        delete userFees[msg.sender];

        console.log("Payment Successful!");
    }

}
