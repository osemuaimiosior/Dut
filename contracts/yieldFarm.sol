// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YieldFarming is ERC20{
    address public immutable owner ;

    constructor() ERC20("Holi", "HL") {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Unauthorized");
    _;
    }

    function addPool(uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) public {}

    function depositWei(uint poolId) public payable {}

    function withdrawWei(uint poolId, uint amount) public {}

    function claimRewards(uint poolId) public {}

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {}

    function checkUserDeposits(address user) public view returns (uint, uint) {}

    function checkUserDepositInPool(uint poolId) public view returns (address[] memory, uint[] memory) {}

    function checkClaimableRewards(uint poolId) public view returns (uint) {}

    function checkRemainingCapacity(uint poolId) public view returns (uint) {}

    function checkWhaleWallets() public view returns (address[] memory) {}

}

