// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@skalenetwork/confidential-token/MintableConfidentialToken.sol";

contract PrivateStakingToken is MintableConfidentialToken {
    
    constructor(address initialAuthority) 
        MintableConfidentialToken(
            "Private Staking Token",
            "PST",
            "1",
            initialAuthority
        ) 
    {}
}