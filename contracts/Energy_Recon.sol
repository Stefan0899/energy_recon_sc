// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
interface IEnergyToken {
    function clawback(address from, uint256 amount) external;
}
contract Energy_Recon {
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
        uint256 distributionFee;
        uint256 transmissionFee;
        uint256 generatorFee;
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
    mapping(address => EnergyUsage) public userUsage;
    mapping(address => EnergyUsage) public userGeneratorUsage;
    mapping(address => EnergyOdometer) public userOdometers;

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
    function assignProviderToUser(address _user) public onlyOwner {
        require(userProvider[_user] == address(0), "User already has a provider"); // Prevent reassignment
        userProvider[_user] = msg.sender; // Assign the calling provider to the user
    }

        // ✅ Assign Distributor to User
    function assignDistributorToUser(address _user) public onlyOwner {
        require(userDistributor[_user] == address(0), "User already has a distributor"); // Prevent reassignment
        userDistributor[_user] = msg.sender; // Assign the calling distributor to the user
    }

    // ✅ Assign Transmittor to User
    function assignTransmittorToUser(address _user) public onlyOwner {
        require(userTransmittor[_user] == address(0), "User already has a transmittor"); // Prevent reassignment
        userTransmittor[_user] = msg.sender; // Assign the calling transmittor to the user
    }

    // ✅ Assign Generator to User
    function assignGeneratorToUser(address _user) public onlyOwner {
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
    function getTokenBalances(address _user, address epToken, address esToken, address eoToken) 
        internal view returns (uint32 epTokens, uint32 esTokens, uint32 eoTokens) 
    {
        IERC20 ep = IERC20(epToken);
        IERC20 es = IERC20(esToken);
        IERC20 eo = IERC20(eoToken);

        uint256 epBalance = ep.balanceOf(_user);
        uint256 esBalance = es.balanceOf(_user);
        uint256 eoBalance = eo.balanceOf(_user);

        return (
            uint32(epBalance / 1e18),
            uint32(esBalance / 1e18),
            uint32(eoBalance / 1e18)
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

        // ✅ Set previous ODOs to 0 if they are not initialized
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

    function calculateAndStoreGeneratorUsage(
        address _user,
        address _EpToken,
        address _EsToken,
        address _EoToken
    ) internal {
        // ✅ Fetch total energy usage from storage
        EnergyUsage memory usage = userUsage[_user];

        // ✅ Fetch token balances
        (uint32 epTokens, uint32 esTokens, uint32 eoTokens) = getTokenBalances(_user, _EpToken, _EsToken, _EoToken);


        // ✅ Store the balances in `endOfMonthBalances`
        endOfMonthBalances[_user] = EnergyUsage(epTokens, esTokens, eoTokens);

        // ✅ Calculate distributor energy usage (subtracting token balances)
        uint32 gen_peakUsage = epTokens >= usage.peakUsage ? 0 : usage.peakUsage - epTokens;
        uint32 gen_stdUsage = esTokens >= usage.stdUsage ? 0 : usage.stdUsage - esTokens;
        uint32 gen_offUsage = eoTokens >= usage.offUsage ? 0 : usage.offUsage - eoTokens;

        // ✅ Store calculated distributor usage
        userGeneratorUsage[_user] = EnergyUsage(gen_peakUsage, gen_stdUsage, gen_offUsage);
    }

    function calculateFees(
        uint32 peakUsage, uint32 stdUsage, uint32 offUsage,
        uint32 upstream_peakTariff, uint32 upstream_standardTariff, uint32 upstream_offpeakTariff, 
        uint32 downstream_peakTariff, uint32 downstream_standardTariff, uint32 downstream_offpeakTariff, uint32 downstream_basicTariff
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

        uint256 pUsage = uint256(peakUsage);
        uint256 sUsage = uint256(stdUsage);
        uint256 oUsage = uint256(offUsage);

        // ✅ Cap energy tokens to prevent excessive multiplication
        require(pUsage <= 1e6 && sUsage <= 1e6 && oUsage <= 1e6, "Token balances too large"); 

        // ✅ Use `unchecked` to prevent overflow reverts when safe
        unchecked {
            peakFee = (peakTariffDiff * pUsage * 100)/100;
            standardFee = (standardTariffDiff * sUsage *100)/100;
            offpeakFee = (offpeakTariffDiff * oUsage *100)/100;
        }

        // ✅ Perform division before multiplying by `1e18` to prevent large numbers
        uint256 totalFee = (peakFee + standardFee + offpeakFee + downstream_basicTariff);
    
        return (totalFee * 1e11); // ✅ Safe conversion to ETH format
    }

    // ✅ Provider assigns a bill based on stored total usage
    function eomRecon(
        address _user,
        address _EpToken,
        address _EsToken,
        address _EoToken,
        uint32 _newPeakODO,
        uint32 _newStdODO,
        uint32 _newOffODO
    ) public onlyProvider {
        //Stakeholders registered

        //Tariffs set

        //Calculate Total Usage, Updates storgae of TotalUsage and ODOS
        calculateTotalUsage(_user, _newPeakODO, _newStdODO, _newOffODO);

        //Calculate Distributor Usage, Updates storage on distributor usage and EOM token balances
        calculateAndStoreGeneratorUsage(_user, _EpToken, _EsToken, _EoToken);

        //Calculate Energy fee, distribution fee, and transmission fee, and store these values
        storeFees(_user);

        // Step 6: Retrieve Stored End-of-Month Balances
        EnergyUsage memory eomBalances = endOfMonthBalances[_user];

        if (eomBalances.peakUsage > 0) {  
            uint256 remainingBalance = IERC20(_EpToken).balanceOf(_user);
            IEnergyToken(_EpToken).clawback(_user, remainingBalance);
        }
        if (eomBalances.stdUsage > 0) {  
            uint256 remainingBalance = IERC20(_EsToken).balanceOf(_user);
            IEnergyToken(_EsToken).clawback(_user, remainingBalance);
        }
        if (eomBalances.offUsage > 0) {  
            uint256 remainingBalance = IERC20(_EoToken).balanceOf(_user);
            IEnergyToken(_EoToken).clawback(_user, remainingBalance);
        }

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
        EnergyUsage memory genUsage = userGeneratorUsage[_user];
        EnergyUsage memory totalUsage = userUsage[_user];
        
        // ✅ Ensure peakUsage does not exceed totalUsage.peakUsage
        uint32 peakUsage = eomBalances.peakUsage > totalUsage.peakUsage ? totalUsage.peakUsage : eomBalances.peakUsage;
        uint32 stdUsage = eomBalances.stdUsage > totalUsage.stdUsage ? totalUsage.stdUsage : eomBalances.stdUsage;
        uint32 offUsage = eomBalances.offUsage > totalUsage.offUsage ? totalUsage.offUsage : eomBalances.offUsage;

        // ✅ Calculate Distribution Fee
        uint256 distributionFee = calculateFees(
            peakUsage, stdUsage, offUsage,  
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff,
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff, distributorTariff.basicTariff
        );

        // ✅ Calculate Transmission Fee
        uint256 transmissionFee = calculateFees(
            peakUsage, stdUsage, offUsage,  
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff,
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff, transmittorTariff.basicTariff
        );

        // ✅ Calculate Generation Fee (No Adjustment Needed)
        uint256 generationFee = calculateFees(
            genUsage.peakUsage, genUsage.stdUsage, genUsage.offUsage,
            0,0,0,
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff, generatorTariff.basicTariff
        );


        // ✅ Calculate `providerFee` as 0.5% of the total fee amount
        uint256 providerFee = ((distributionFee + transmissionFee + generationFee) *5 )/ 1000; // 0.5% of total fees
        
        //Total bill
        uint256 totalBill = distributionFee + transmissionFee + generationFee + providerFee;

        userFees[_user] = Fees(distributionFee, transmissionFee, generationFee, providerFee, totalBill);
    }

    function viewAllUserData(address _user) 
        public 
        view 
        returns (
            uint32 peakUsage, uint32 stdUsage, uint32 offUsage,  // Total Usage
            uint32 gen_peakUsage, uint32 gen_stdUsage, uint32 gen_offUsage, // Distributor Usage
            uint32 epBalance, uint32 esBalance, uint32 eoBalance, // Token Balances
            uint256 energyFee, uint256 distributionFee, uint256 transmissionFee, uint256 providerFee, uint256 totalBill, // Fees
            uint32 distributorPeakTariff, uint32 distributorStandardTariff, uint32 distributorOffpeakTariff, uint32 distributorBasicTariff, // Distributor Tariffs
            uint32 transmittorPeakTariff, uint32 transmittorStandardTariff, uint32 transmittorOffpeakTariff, uint32 transmittorBasicTariff, // Transmittor Tariffs
            uint32 generatorPeakTariff, uint32 generatorStandardTariff, uint32 generatorOffpeakTariff, uint32 generatorBasicTariff, // Generator Tariffs
            uint32 peakODO, uint32 stdODO, uint32 offODO //ODOs
        ) 
    {
        // ✅ Fetch stored Total Energy Usage
        EnergyUsage memory totalUsage = userUsage[_user];

        // ✅ Fetch stored Distributor Energy Usage
        EnergyUsage memory genUsage = userGeneratorUsage[_user];

        // ✅ Fetch stored End-of-Month Token Balances
        EnergyUsage memory eomBalances = endOfMonthBalances[_user];

        // ✅ Fetch stored Fees
        Fees memory fees = userFees[_user];

        // ODOs
        EnergyOdometer memory odos = userOdometers[_user];

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
            genUsage.peakUsage, genUsage.stdUsage, genUsage.offUsage, // Distributor Usage
            eomBalances.peakUsage, eomBalances.stdUsage, eomBalances.offUsage, // Token Balances
            fees.distributionFee, fees.transmissionFee, fees.generatorFee, fees.providerFee, fees.totalBill, // Fees
            distributorTariff.peakTariff, distributorTariff.standardTariff, distributorTariff.offpeakTariff, distributorTariff.basicTariff, // Distributor Tariffs
            transmittorTariff.peakTariff, transmittorTariff.standardTariff, transmittorTariff.offpeakTariff, transmittorTariff.basicTariff, // Transmittor Tariffs
            generatorTariff.peakTariff, generatorTariff.standardTariff, generatorTariff.offpeakTariff, generatorTariff.basicTariff, // Generator Tariffs
            odos.peakODO, odos.stdODO, odos.offODO //ODOs
        );
    }

    function payEnergyFees() public payable {
        require(userProvider[msg.sender] != address(0), "No provider assigned to this user");
        require(userDistributor[msg.sender] != address(0), "No distributor assigned to this user");
        require(userTransmittor[msg.sender] != address(0), "No transmittor assigned to this user");
        require(userGenerator[msg.sender] != address(0), "No generator assigned to this user");

        address payable provider = payable(userProvider[msg.sender]);
        address payable distributor = payable(userDistributor[msg.sender]);
        address payable transmittor = payable(userTransmittor[msg.sender]);
        address payable generator = payable(userGenerator[msg.sender]);

        Fees memory userFee = userFees[msg.sender];

        require(userFee.totalBill > 0, "No outstanding bill for this user");

        uint256 distributionFee = (userFee.distributionFee);
        uint256 transmissionFee = (userFee.transmissionFee);
        uint256 generatorFee = (userFee.generatorFee);
        uint256 providerFee = (userFee.providerFee);
        uint256 totalBillETH = (userFee.totalBill);

        console.log("Expected Total Bill (wei):", totalBillETH);
        console.log("Distribution Fee (wei):", distributionFee);
        console.log("Transmission Fee (wei):", transmissionFee);
        console.log("Generation Fee (wei):", generatorFee);
        console.log("Provider Fee (wei):", providerFee);
        console.log("msg.value (wei):", msg.value);

        require(msg.value >= totalBillETH, "Insufficient ETH sent");

        // ✅ Perform transfers
        distributor.transfer(distributionFee);
        transmittor.transfer(transmissionFee);
        generator.transfer(generatorFee);
        provider.transfer(providerFee);

        delete userFees[msg.sender];

        console.log("Payment Successful!");
    }

}
