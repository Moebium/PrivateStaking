# PrivateStaking 🔒

A DeFi staking protocol deployed on SKALE blockchain.
Built for the SKALE Programmable Privacy Hackathon 2026.

## Live Contract
Network: SKALE Base Sepolia Testnet
Address: `0x185275D723bCeDB6953652797b8a6f3107Bdaebf`

## What it does
- Users stake ETH and earn 10% reward
- 30-day lock period enforced on-chain
- Zero gas fees on SKALE network

## Stack
- Solidity ^0.8.18
- Foundry
- OpenZeppelin
- SKALE Network

## Deploy
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://testnet.skalenodes.com/v1/giant-half-dual-testnet \
  --broadcast --legacy
