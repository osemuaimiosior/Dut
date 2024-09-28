// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract yieldFarm is ERC20 {
    address public immutable owner ;

    constructor() ERC20("Holi", "HL") {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Unauthorized");
    _;
    }

    struct poolDetails {
        uint _maxAmount; 
        uint _yieldPercent; 
        uint _minDeposit; 
        uint _rewardTime; //Number of days to maturity
        uint _currentAmount;
    }

    struct userDeposit {
        uint _poolId;
        uint timestamp;
        uint _amount;
    }

    uint Id = 1;

    mapping(uint => poolDetails) listOfPools;
    mapping(uint => mapping(address => userDeposit)) depositLogs;
    mapping(address => mapping(uint => userDeposit)) userPoolDepositInfo;
    mapping(address => uint[]) public usersPool;
    mapping(uint => address[]) public arrayOfPoolDepositors;
    mapping(address => uint) public userTotalDeposit;
    mapping(address => uint) userTotalClaims;

    function addPool(uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) public onlyOwner {
        poolDetails memory newPool = poolDetails(
            maxAmount,
            yieldPercent,
            minDeposit, 
            rewardTime,
            0
        );

        listOfPools[Id] = newPool;
        Id += 1;
    }

    function depositWei(uint poolId, uint amount) public payable {
        poolDetails memory depositingPool = listOfPools[poolId];

        require(amount >= depositingPool._minDeposit, "Add more wei to depositing amount");
        require((poolId <= Id && poolId >= 0), "Invalid Pool");
        require(depositLogs[poolId][msg.sender]._poolId != poolId , "Unathorized");

        arrayOfPoolDepositors[poolId].push(msg.sender);
        listOfPools[poolId]._currentAmount += amount;
        depositLogs[poolId][msg.sender] = userDeposit(poolId, block.timestamp, amount);
        
        userTotalDeposit[msg.sender] += amount;
        usersPool[msg.sender].push(poolId);
    }

    function withdrawWei(uint poolId, uint amount) public payable{
        require(depositLogs[poolId][msg.sender]._amount >= amount, "Invalid transaction");

        depositLogs[poolId][msg.sender]._amount -= amount;
         //(bool sent, bytes memory data) = msg.sender.call{value: amount}("");
         (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function claimRewards(uint poolId) public {
         // Number of seconds in a day
        uint256 secondsInDay = 86400;
        uint depositDate = depositLogs[poolId][msg.sender].timestamp;
        uint daysCount = listOfPools[poolId]._rewardTime;

        uint timePeriodInDays = (block.timestamp - depositDate)/secondsInDay;
        require(timePeriodInDays > 0, "Invalid trasaction");

        uint yieldClaims = (timePeriodInDays % daysCount) * listOfPools[poolId]._yieldPercent;
        uint claims = yieldClaims * depositLogs[poolId][msg.sender]._amount;

        (bool sent, ) = msg.sender.call{value: claims}("");
        require(sent, "Failed to send Ether");
    }

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {
        require(poolId < Id && poolId > 0, "Invalid Pool");
        poolDetails memory result = listOfPools[poolId];
        
        return (result._maxAmount, result._yieldPercent, result._minDeposit, result._rewardTime);
    }

    function checkUserDeposits(address user) public view returns (uint, uint) {
        uint[] memory userDepositingPools = usersPool[user];
        uint deposit = userTotalDeposit[user];
        uint claims = 0;

        if(deposit == 0){
            return (deposit, 0);
        } else {
            for(uint i = 0; i < userDepositingPools.length; i++){
                 uint256 secondsInDay = 86400;
                 uint depositDate = depositLogs[userDepositingPools[i]][user].timestamp;
                 uint daysCount = listOfPools[userDepositingPools[i]]._rewardTime;

                 uint timePeriodInDays = (block.timestamp - depositDate)/secondsInDay;

                 uint yieldClaims = (timePeriodInDays % daysCount) * listOfPools[userDepositingPools[i]]._yieldPercent;
                 claims += yieldClaims * depositLogs[userDepositingPools[i]][user]._amount;
            }

            return (deposit, claims);
        }
    }

    function checkUserDepositInPool(uint poolId) public view returns (address[] memory, uint[] memory) {
        address[] memory depositors = arrayOfPoolDepositors[poolId];
        uint[] memory amounts = new uint[](depositors.length);

        for(uint i =0; i < depositors.length; i++){
            uint deposit = depositLogs[poolId][depositors[i]]._amount;
            amounts[i] = deposit;
        }

        return (depositors, amounts);
    }

    function checkClaimableRewards(uint poolId) public view returns (uint) {}

    function checkRemainingCapacity(uint poolId) public view returns (uint) {}

    function checkWhaleWallets() public view returns (address[] memory) {}

}
