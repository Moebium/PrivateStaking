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
    event RewardClaimed(address indexed user, uint256 reward);

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
    function stake(uint256 _amount) public onlyNotStaking {
        require(_amount > 0, "Amount must be more than 0");
        StakeInfo storage userStake = stakes[msg.sender];
        userStake.amount = _amount;
        userStake.timestamp = block.timestamp;
        userStake.isStaking = true;
        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function unstake() public {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.isStaking, "You are not staking");
        require(block.timestamp >= userStake.timestamp + LOCK_PERIOD, "Lock period not over");
        
        uint256 rewardAmount = (userStake.amount * REWARD_RATE) / 100;
        userStake.reward = rewardAmount;

        uint256 amountToTransfer = userStake.amount;
        
        // Reset everything before transfer (security pattern)
        userStake.amount = 0;
        userStake.timestamp = 0;
        userStake.isStaking = false;

        payable(msg.sender).transfer(amountToTransfer);
        emit Unstaked(msg.sender, amountToTransfer);
    }

    function claimReward() public {
        StakeInfo storage userStake = stakes[msg.sender];

        require(!userStake.isStaking, "Must unstake principal first");
        require(userStake.reward > 0, "No reward to claim");

        uint256 rewardToTransfer = userStake.reward;
        userStake.reward = 0;

        payable(msg.sender).transfer(rewardToTransfer);
        emit RewardClaimed(msg.sender, rewardToTransfer);
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