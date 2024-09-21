// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract yieldFarm is ERC20("YieldFarming", "YF"){

    struct poolDetails{
        string _poolName;
        uint _maxAmount;
        uint _yeildPercent;
        uint _minDeposit;
        uint _rewardTime;
    }

    mapping(uint => poolDetails) public poolDirectory;

    uint poolID = 0;

    function addPool( string memory poolName, uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) public returns(string memory done) {
        poolDetails memory details = poolDetails(poolName, maxAmount, yieldPercent, minDeposit, rewardTime);
        poolDirectory[poolID] = details;
        poolID += 1;
        return "Done";
    }

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {
        poolDetails memory details = poolDirectory[poolId];
        return (details._maxAmount, details._yeildPercent, details._minDeposit, details._rewardTime);
    }
}