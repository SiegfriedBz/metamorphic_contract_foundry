# Metamorphic Contracts with Foundry

This Foundry project demonstrates the use of **metamorphic contracts** by leveraging a combination of `CREATE2`, `CREATE`, and `selfdestruct` to deploy different contracts (`A` and `B`) **at the same address** across separate transactions.

## ⚙️ Overview

The pattern uses the fact that:

- `CREATE2` allows deploying a contract at a deterministic address based on the deployer address, salt, and bytecode.
- `CREATE` computes new contract addresses using the sender's address and nonce.
- `selfdestruct` (when used in the same transaction as deployment) can remove a contract and reset the nonce of the address, enabling redeployment of different logic to the **same address**.

> ⚠️ Note: As per [EIP-6780](https://eips.ethereum.org/EIPS/eip-6780) (introduced with the Cancun hard fork), `selfdestruct` only removes contract code and storage **if used in the same transaction as the deployment**.

## 🧱 Contracts

- `A`: A simple contract with `getVersion()` and `kill()` (calls `selfdestruct`).
- `B`: Another simple contract with only `getVersion()`.
- `Factory`: Deploys `A` or `B` using `CREATE`, and can destroy itself via `selfdestruct`.

## 🧪 Test: `MetamorphicTest.t.sol`

The test workflow:

1. Deploy the `Factory` using `CREATE2`.
2. Use it to deploy contract `A` via `CREATE`.
3. Destroy `A` and the `Factory`.
4. Redeploy the same `Factory` using `CREATE2` (same salt => same address).
5. Use the new factory to deploy `B` via `CREATE` — **at the same address `A` previously occupied**.
6. Assert that `address(A) == address(B)`.

## 🔁 Deployment Addresses Summary

- `Factory`: Deployed using `CREATE2` => address is deterministic.
- `A` and `B`: Deployed using `CREATE` => address depends on factory’s address and nonce.
- Because the factory is destroyed and recreated, the nonce is reset, enabling `B` to occupy the former address of `A`.
