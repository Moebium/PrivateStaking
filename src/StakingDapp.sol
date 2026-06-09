// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract StakingDapp {

    // 1. State variables
    uint256 public constant LOCK_PERIOD = 30 days;
    uint256 public constant REWARD_RATE = 10;
    address public owner;

    // 2. Struct
    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 reward;
        bool isStaking;
    }

    // 3. Mappings
    mapping(address => StakeInfo) public stakes;

    // 4. Events
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed user, uint256 amount);
    event EmergencyUnstaked(address indexed user, uint256 returned, uint256 penalty);
   
    // 5. Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyNotStaking() {
        require(!stakes[msg.sender].isStaking, "Already staking!");
        _;
    }

    // 6. Constructor
    constructor() {
        owner = msg.sender;
    }

    // 7. Functions
    function stake() public payable onlyNotStaking {
        require(msg.value > 0, "Amount must be more than 0");
        StakeInfo storage userStake = stakes[msg.sender];
        userStake.amount = msg.value;
        userStake.timestamp = block.timestamp;
        userStake.isStaking = true;
        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    function unstake() public {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.isStaking, "You are not staking");
        require(block.timestamp >= userStake.timestamp + LOCK_PERIOD, "Lock period not over");
        
        uint256 rewardAmount = (userStake.amount * REWARD_RATE) / 100;
        uint256 totalToTransfer = userStake.amount + rewardAmount;
        
        userStake.amount = 0;
        userStake.timestamp = 0;
        userStake.reward = 0;
        userStake.isStaking = false;

        payable(msg.sender).transfer(totalToTransfer);
        emit Unstaked(msg.sender, totalToTransfer);
    }

    function emergencyUnstake() public {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.isStaking, "No active stake found");
        require(block.timestamp < userStake.timestamp + LOCK_PERIOD, "Lock period is over, use regular unstake");

        uint256 stakedAmount = userStake.amount;
        uint256 penalty = (stakedAmount * 5) / 100;
        uint256 amountToReturn = stakedAmount - penalty;

        userStake.amount = 0;
        userStake.timestamp = 0;
        userStake.reward= 0;
        userStake.isStaking = false;
        
        (bool success, ) = payable(msg.sender).call{value: amountToReturn} ("");
        require(success, "Transfer Failed");

        emit EmergencyUnstaked(msg.sender, amountToReturn, penalty);

    }
    function depositRewardPool() public payable onlyOwner {
        require(msg.value > 0, "Must deposit more than 0");
    }
    // 8. View functions
    function getStakeInfo(address _user) public view returns (uint256 amount, uint256 timestamp,  uint256 reward, bool isStaking) {
        StakeInfo memory tempStake = stakes[_user];
        return (tempStake.amount, tempStake.timestamp, tempStake.reward, tempStake.isStaking);
    }

    function getTimeLeft(address _user) public view returns (uint256) {
        StakeInfo memory userStake = stakes[_user];

        if (!userStake.isStaking) {
            return 0;
        }

        uint256 unlockTime = userStake.timestamp + LOCK_PERIOD;

        if (block.timestamp >= unlockTime) {
            return 0;
        } else {
            return unlockTime - block.timestamp;
        }
    }
}