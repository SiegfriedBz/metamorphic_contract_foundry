## Metamorphic Contract demo with Foundry

This Foundry project demonstrates the use of metamorphic contracts by leveraging a combination of CREATE2, CREATE, and selfdestruct to deploy different contracts (A and B) at the same address across separate transactions.

### ⚙️ Overview

This pattern is made possible by the interplay between:

- CREATE2 → deploys contracts at deterministic addresses (based on deployer address, salt, and bytecode).

- CREATE → deploys contracts at addresses computed from the deployer's address and its current nonce.

- selfdestruct → can remove a contract and (if used in the same transaction as deployment) resets the nonce of the corresponding account.

⚠️ Note: As of [EIP-6780](https://eips.ethereum.org/EIPS/eip-6780) (introduced with the Cancun hard fork), selfdestruct only removes code and storage if used in the same transaction as deployment.

### 🧱 Contracts

- A: Simple contract exposing getVersion() and kill() (calls selfdestruct).

- B: Similar to A, but with only getVersion().

- Factory: Deploys contracts A and B using CREATE, and can destroy itself with selfdestruct.

The Factory contains deployment functions for both A and B, ensuring the bytecode remains consistent across deployments (important for CREATE2 determinism).

### 🧪 Test: MetamorphicTest.t.sol

The test follows this sequence:

- Deploy Factory with CREATE2 (using a fixed salt).

- Use the factory to deploy contract A via CREATE.

- Call kill() on A to destroy it.

- Destroy the Factory.

- Redeploy the same Factory (same salt → same address) using CREATE2.

- Use the new factory to deploy contract B via CREATE.

- Assert that address(A) == address(B) — i.e., B replaces A at the same address.

### 🔁 Deployment Addresses Summary

- Factory: Deployed using CREATE2 → deterministic address.

- A and B: Deployed using CREATE → address depends on Factory’s address and its nonce.

Because the factory is destroyed and recreated, its nonce resets, enabling B to be deployed at the same address as A.

### 🚀 Getting Started

```bash
git clone https://github.com/SiegfriedBz/metamorphic_contract_foundry .
forge install
forge test -vvv
```
