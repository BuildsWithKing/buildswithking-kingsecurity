[![Solidity](https://img.shields.io/badge/Solidity-^0.8.30-lightgrey?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20With-Foundry-blue)](https://book.getfoundry.sh/)
[![Tests](https://img.shields.io/badge/Tests-Unit%20%7C%20Fuzz%20%7C%20Mocks-success)](https://book.getfoundry.sh/forge/writing-tests)
[![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen)](Screenshot/image.png)
[![Security](https://img.shields.io/badge/Security-Audit--Ready-critical)](https://github.com/BuildsWithKing/BuildsWithKing-KingSecurity)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen)](STATUS)


---
![BuildsWithKing-KingSecurity](Screenshot/logo.jpg)

**A modular, audit-ready Solidity security suite — by @BuildsWithKing.**

---

# 🛡 BuildsWithKing-KingSecurity
**A modular Solidity security framework for building safer, auditable smart contracts.**

KingSecurity is designed around the idea that smart contract security should be modular, auditable, and human-readable. Every module enforces one invariant and can be combined like building blocks.

This repository introduces modular smart contract security primitives such as **Kingable**, **KingPausable**, hybrid extensions, **KingClaimMistakenETH**, **KingReentrancyGuard**, **KingERC20** and **KingReentrancyAttacker**. Battle-tested with **unit tests**, **fuzz tests**, and **mock contracts** using Foundry.

> ⚠ Note: This repository serves as a testing and experimental workspace for the buildswithking-security library.
It is not versioned, and features here may change without notice.
For stable modules, use the main [BuildsWithKing-Security](https://github.com/BuildsWithKing/buildswithking-security) repo.

---

## Table of Contents
Audit-ready, modular Solidity security suite tested with Foundry.

- [🛡 BuildsWithKing-KingSecurity](#-buildswithking-kingsecurity)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Motivation](#motivation)
  - [Core Contracts](#core-contracts)
  - [Extensions](#extensions)
  - [Guards](#guards)
  - [Security](#security)
  - [Tokens/ERC20](#tokenserc20)
    - [KingERC20.sol](#kingerc20sol)
    - [Extensions](#extensions-1)
    - [Interfaces](#interfaces)
    - [Errors](#errors)
  - [Utils](#utils)
  - [Testing Strategy](#testing-strategy)
    - [Unit Tests](#unit-tests)
    - [Fuzz Tests](#fuzz-tests)
    - [Mocks](#mocks)
  - [Coverage](#coverage)
  - [File Structure](#file-structure)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Clone \& Install](#clone--install)
    - [Build \& Test](#build--test)
    - [Check Coverage with:](#check-coverage-with)
    - [Gas snapshot](#gas-snapshot)
  - [Installation:](#installation)
  - [Usage](#usage)
  - [Security Considerations](#security-considerations)
  - [Author](#author)
  - [License](#license)

---

## Overview
This **KingSecurity suite** enforces **ownership, pausing, and authority mechanics** in a way that is:

- ✅ Transparent  
- ✅ Modular  
- ✅ Audit-friendly  

Each module is shipped with:
- **Custom errors** (gas-optimized revert reasons)  
- **Events** (state-change transparency)  
- **Modifiers & Guards** (king-only execution, contract/EOA filtering)  
- **Extensive test coverage** (unit + fuzzing)  

---

## Motivation
Smart contract exploits often arise from **improper access control, missing pause mechanisms, or weak invariants**.  
This project tackles those pain points by building **security extensions** that can be plugged into larger protocols.

> This repository is not a step-by-step guide, but a reference testing suite for the main [BuildsWithKing-Security](https://github.com/BuildsWithKing/buildswithking-security) repository.

---

## Core Contracts
1. **Kingable.sol**  
   - Introduces the **“King” role** (customizable ownership).  
   - Supports *transferring* and *renouncing* kingship.  

2. **KingImmutable.sol**  
   - Immutable king set at deployment.  
   - No transfer or renounce allowed (*one true king forever*). 

3. **KingAccessControlLite.sol**
   - Minimal and Gas-efficient role-based access control module for king-based contracts.

---

## Extensions
1. **KingPausable.sol**  
   - Pause/Activate core functions.  
   - Prevents unexpected activity during upgrades or active exploit scenarios.  

2. **KingableContracts.sol**  
   - Restricts kingship transfer to *contract addresses only*.  

3. **KingableEOAs.sol**  
   - Restricts kingship transfer to *externally owned accounts (EOAs)* only.  

4. **KingablePausable.sol**  
   - Hybrid extension combining *Kingable + Pausable* in one contract.  

---

## Guards
1. **KingClaimMistakenETH.sol**
   - Allows users to claim ETH mistakenly transferred to the child contract. 

2. **KingRejectETH.sol**
   - Rejects ETH transfer on child contracts. 

---

## Security
1. **KingReentrancyGuard.sol**
   - Prevents reentrancy attacks using the `nonReentrant` modifier. 

## Tokens/ERC20

### KingERC20.sol
   - Core, modular ERC-20 implementation (balances, transfers, allowances, events).  
   - Built to be inherited by extensions (mintable, burnable, capped) so the base remains minimal and auditable.  
   - Uses *custom errors* and *address validation* for gas efficiency and clearer reverts.  

### Extensions
1. KingERC20Burnable.sol
   - *Role-based burning extension* leveraging KingAccessControlLite.
   - Allows the King to assign/remove BURNER_ROLE and authorized burner to burn tokens.  
   - Designed to integrate with any ERC20 needing controlled burn logic; calls _burn on the base contract.  

2. KingERC20Capped.sol
   - Enforces a *maximum supply cap*, preventing minting above the defined limit.  
   - Overrides _mint to check s_totalSupply + amount <= cap.  
   - Ideal for tokens with *fixed maximum issuance*.  

3. KingERC20Mintable.sol
   - *Role-based minting extension* leveraging KingAccessControlLite.  
   - Allows the King to assign/remove MINTER_ROLE and authorized minters to mint tokens.  
   - Suitable for controlled inflation, staking rewards, or staged issuance.  

4. KingERC20Pausable.sol
   - Adds *emergency whenActive* gating to core write functions (transfer, approve, mint, burn).  
   - Inherits behavior from KingPausable; enhances safety during maintenance, upgrades, or exploit responses.  

### Interfaces
1. IERC20.sol
   - Minimal ERC-20 interface defining *core events and functions*.  
   - Ensures *interoperability* and standard compliance with ERC-20 ecosystem tools.  

2. IERC20Metadata.sol
   - ERC-20 *metadata interface* exposing name, symbol, and decimals.  
   - Keeps the base contract lightweight and modular.  

### Errors
1. KingERC20Errors.sol
   - Centralized collection of *custom errors* for the entire ERC-20 stack (e.g., InsufficientBalance, ZeroInitialSupply).  
   - Reduces duplicate revert messages and saves gas compared to require strings.  

## Utils
1. **KingReentrancyAttacker.sol**
   - Reusable attacker contract for testing reentrancy vulnerabilities.

2. **KingVulnerableContract.sol**
   - A deliberately insecure contract used to simulate reentrancy attacks. 
  
3. **KingCheckAddressLib.sol**
- Lightweight *utility library* that validates addresses.  
- Replaces repetitive `if(account == address(0))` checks for cleaner code.  
- Gas-efficient and improves *consistency across contracts*.

## Testing Strategy
Testing is powered by **Foundry**.  
All contracts are verified against *unit, fuzz, and mock tests* to ensure correctness, robustness, and edge-case coverage. 

> All tests were written manually and run under Foundry `1.2.3-stable`.

### Unit Tests
- Verifies constructor initialization and state setup.  
- Validate access control (Unauthorized, InvalidKing, etc.).  
- Confirm expected state transitions.  

### Fuzz Tests
- Stress test random inputs across key functions (transferKingship, pauseContract, activateContract).  
- Ensure safety invariants hold under arbitrary addresses.  

### Mocks
- Enable isolated testing of **abstract contracts**. 
- Dummy contracts simulate invalid inputs (e.g., contract vs. EOA).  
 
---

## Coverage
Below is the current coverage report snapshot (100%).
![alt text](Screenshot/image.png)


## File Structure
This tree illustrates a 1:1 mapping between production modules and their corresponding test suites (unit, fuzz, mock).
```bash

src
├── core
│   ├── KingAccessControlLite.sol
│   ├── KingImmutable.sol
│   └── Kingable.sol
├── extensions
│   ├── KingPausable.sol
│   ├── KingableContracts.sol
│   ├── KingableEOAs.sol
│   └── KingablePausable.sol
├── guards
│   ├── KingClaimMistakenETH.sol
│   └── KingRejectETH.sol
├── security
│   └── KingReentrancyGuard.sol
├── tokens
│   ├── ERC20
│   │   ├── KingERC20.sol
│   │   ├── extensions
│   │   │   ├── KingERC20Burnable.sol
│   │   │   ├── KingERC20Capped.sol
│   │   │   ├── KingERC20Mintable.sol
│   │   │   └── KingERC20Pausable.sol
│   │   └── interfaces
│   │       ├── IERC20.sol
│   │       └── IERC20Metadata.sol
│   └── errors
│       └── KingERC20Errors.sol
└── utils
|   ├── KingCheckAddressLib.sol
|   ├── KingReentrancyAttacker.sol
|   └── KingVulnerableContract.sol
|
test
├── fuzz
│   ├── corefuzz
│   │   ├── KingAccessControlLiteFuzzTest.t.sol
│   │   └── KingableFuzzTest.t.sol
│   ├── extensionsFuzz
│   │   ├── KingPausableFuzzTest.t.sol
│   │   ├── KingableContractsFuzzTest.t.sol
│   │   ├── KingableEOAsFuzzTest.t.sol
│   │   └── KingablePausableFuzzTest.t.sol
│   └── guardsfuzz
│       └── KingClaimMistakenETHFuzzTest.t.sol
├── mocks
│   ├── KingAccessControlLiteMockTest.t.sol
│   ├── KingClaimMistakenETHMockTest.t.sol
│   ├── KingERC20BurnableMockTest.t.sol
│   ├── KingERC20CappedMockTest.t.sol
│   ├── KingERC20MintableMockTest.t.sol
│   ├── KingERC20MockTest.t.sol
│   ├── KingERC20PausableMockTest.t.sol
│   ├── KingImmutableMockTest.t.sol
│   ├── KingPausableMockTest.t.sol
│   ├── KingRejectETHMockTest.t.sol
│   ├── KingableContractsMockTest.t.sol
│   ├── KingableEOAsMockTest.t.sol
│   ├── KingableMockTest.t.sol
│   └── KingablePausableMockTest.t.sol
└── unit
    ├── BaseTest.t.sol
    ├── DummyContract.t.sol
    ├── coreunit
    │   ├── KingAccessControlLiteUnitTest.t.sol
    │   ├── KingImmutableUnitTest.t.sol
    │   └── KingableUnitTest.t.sol
    ├── extensionsunit
    │   ├── KingPausableUnitTest.t.sol
    │   ├── KingableContractsUnitTest.t.sol
    │   ├── KingableEOAsUnitTest.t.sol
    │   └── KingablePausableUnitTest.t.sol
    ├── guardsunit
    │   ├── KingClaimMistakenETHUnitTest.t.sol
    │   └── KingRejectETHTest.t.sol
    ├── tokens
    │   └── ERC20
    │       ├── KingERC20FuzzTest.t.sol
    │       ├── KingERC20UnitTest.t.sol
    │       └── extensionsunit
    │           ├── KingERC20BurnableUnitTest.t.sol
    │           ├── KingERC20CappedUnitTest.t.sol
    │           ├── KingERC20MintableUnitTest.t.sol
    │           └── KingERC20PausableUnitTest.t.sol
    └── utilsunit
        └── KingReentracyAttackerUnitTest.t.sol
```

---

## Getting Started

### Prerequisites

[Foundry](https://book.getfoundry.sh/getting-started/installation) install

To explore or run tests locally:

### Clone & Install
```
git clone https://github.com/BuildsWithKing/BuildsWithKing-KingSecurity.git
cd BuildsWithKing-KingSecurity
forge install
```
### Build & Test
```
forge build
forge test -vvvv
```
---

### Check Coverage with:
```
forge coverage
```

### Gas snapshot
```
forge snapshot
```

## Installation: 

Install this package into your Foundry/Hardhat project by adding it as a Git submodule or using forge install:

```solidity
forge install BuildsWithKing/buildswithking-security
```
Then import module with:

```solidity
import {Kingable} from "buildswithking-security/contracts/access/core/Kingable.sol";
import {KingReentrancyGuard} from "buildswithking-security/contracts/security/KingReentrancyGuard.sol";
```
---

## Usage

To inherit `Kingable` & `KingReentrancyGuard` in your contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Kingable} from "buildswithking-security/contracts/access/core/Kingable.sol";
import {KingReentrancyGuard} from "buildswithking-security/contracts/security/KingReentrancyGuard.sol";

contract MyDapp is KingReentrancyGuard, Kingable {
    constructor(address _kingAddress) Kingable(_kingAddress) {}

    function doKingStuff() external onlyKing nonReentrant {
        // only the King can call this 
    }
}
```

## Security Considerations

This repo is a security primitives library, not a production protocol.

Audit your integration when using these contracts in live deployments.

Includes custom errors and reverts for gas savings and safety.

> Note: These contracts are battle-tested through fuzzing and mocks but should still undergo external audit review before mainnet deployment.

---

## Author

Michealking (@BuildsWithKing)

Solidity Smart Contract Developer

Security-focused, building transparent protocols

📧 buildswithking@gmail.com

📡 Twitter/X: [@BuildsWithKing](https://x.com/BuildsWithKing)

---

⭐ **Star this repo** if you find it helpful — contributions and feedback are welcome!

---

## License

This project is licensed under the MIT License.

---