// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract yieldFarm is ERC20{
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

    uint Id = 0;

    mapping(uint => poolDetails) listOfPools;
    mapping(uint => mapping(address => userDeposit)) depositLogs;

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

    function depositWei(uint poolId) public payable {
        poolDetails memory depositingPool = listOfPools[poolId];

        require(msg.value >= depositingPool._minDeposit, "Add more wei to depositing amount");
        require((poolId <= Id && poolId >= 0), "Invalid Pool");
        require(depositLogs[poolId][msg.sender]._poolId != poolId , "Unathorized");

        depositingPool._currentAmount += msg.value;
        depositLogs[poolId][msg.sender] = userDeposit(poolId, block.timestamp, msg.value);
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

        uint timePeriodInDays = (depositDate - block.timestamp)/secondsInDay;
        require(timePeriodInDays > 0, "Invalid trasaction");

        uint yieldClaims = (timePeriodInDays % daysCount) * listOfPools[poolId]._yieldPercent;
        uint claims = yieldClaims * depositLogs[poolId][msg.sender]._amount;

        (bool sent, ) = msg.sender.call{value: claims}("");
        require(sent, "Failed to send Ether");
    }

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {
        poolDetails memory result = listOfPools[poolId];
        return (result._maxAmount, result._yieldPercent, result._minDeposit, result._rewardTime);
    }
}

