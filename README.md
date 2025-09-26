[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Foundry](https://img.shields.io/badge/Built%20With-Foundry-blue)](https://book.getfoundry.sh/)
[![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen)](Screenshot/image.png)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.30-lightgrey?logo=solidity)](https://soliditylang.org/)
[![Security](https://img.shields.io/badge/Security-Audit--Ready-critical)](https://github.com/BuildsWithKing/BuildsWithKing-KingSecurity)
[![Tests](https://img.shields.io/badge/Tests-Unit%20%7C%20Fuzz%20%7C%20Mocks-success)](https://book.getfoundry.sh/forge/writing-tests)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen)]()
---

# 🛡 BuildsWithKing-KingSecurity

A *security-focused Solidity suite* designed and implemented by *Michealking (@BuildsWithKing)*.  
This repository introduces modular smart contract security primitives such as **Kingable**, **KingPausable**, and hybrid extensions. Battle-tested with **unit tests**, **fuzz tests**, and **mock contracts** using Foundry.

---

## 📑 Table of Contents
- [🛡 BuildsWithKing-KingSecurity](#-buildswithking-kingsecurity)
  - [📑 Table of Contents](#-table-of-contents)
  - [🔒 Overview](#-overview)
  - [💡 Motivation](#-motivation)
  - [🏛 Core Contracts](#-core-contracts)
  - [🧩 Extensions](#-extensions)
  - [🧪 Testing Strategy](#-testing-strategy)
    - [Unit Tests](#unit-tests)
    - [Fuzz Tests](#fuzz-tests)
    - [Mocks](#mocks)
  - [🔐 Coverage](#-coverage)
  - [🌳 File Structure](#-file-structure)
  - [🚀 Getting Started](#-getting-started)
    - [Prerequisites](#prerequisites)
    - [Clone \& Install](#clone--install)
    - [Build \& Test](#build--test)
  - [⚡Installation:](#installation)
  - [🛠️ Usage](#️-usage)
  - [🛡 Security Considerations](#-security-considerations)
  - [✍ Author](#-author)
  - [📜 License](#-license)

---

## 🔒 Overview
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

## 💡 Motivation
Smart contract exploits often arise from **improper access control, missing pause mechanisms, or weak invariants**.  
This project tackles those pain points by building **security extensions** that can be plugged into larger protocols.

> ⚡ This repo is not a tutorial — it’s a production-grade, security-first foundation for Solidity projects.

---

## 🏛 Core Contracts
1. **Kingable.sol**  
   - Introduces the **“King” role** (customizable ownership).  
   - Supports *transferring* and *renouncing* kingship.  

2. **KingImmutable.sol**  
   - Immutable king set at deployment.  
   - No transfer or renounce allowed (*one true king forever*).  

---

## 🧩 Extensions
1. **KingPausable.sol**  
   - Pause/unpause core functions.  
   - Protects against unexpected activity during upgrades or exploits.  

2. **KingableContracts.sol**  
   - Restricts kingship transfer to *contract addresses only*.  

3. **KingableEOAs.sol**  
   - Restricts kingship transfer to *externally owned accounts (EOAs)* only.  

4. **KingablePausable.sol**  
   - Hybrid extension combining *Kingable + Pausable* in one contract.  

---

## 🧪 Testing Strategy
Testing is powered by **Foundry**.  
All contracts are verified against *unit, fuzz, and mock tests* to ensure correctness, robustness, and edge-case coverage.  

### Unit Tests
- Verify constructor behavior.  
- Validate access control (Unauthorized, InvalidKing, etc.).  
- Confirm expected state transitions.  

### Fuzz Tests
- Stress test random inputs across key functions (transferKingship, pauseContract, activateContract).  
- Ensure safety invariants hold under arbitrary addresses.  

### Mocks
- Dummy contracts simulate invalid inputs (*contract vs. EOA*).  
- Enable isolated testing of *abstract contracts*.  

---

## 🔐 Coverage
Below is the current coverage report snapshot (100%).
![alt text](Screenshot/image.png)


## 🌳 File Structure
```bash
.
├── src
│   ├── core
│   │   ├── KingImmutable.sol
│   │   └── Kingable.sol
│   └── extensions
│       ├── KingPausable.sol
│       ├── KingableContracts.sol
│       ├── KingableEOAs.sol
│       └── KingablePausable.sol
└── test
    ├── unit
    │   ├── coreunit
    │   └── extensionsunit
    ├── fuzz
    │   ├── corefuzz
    │   └── extensionsfuzz
    └── mocks
```

---

## 🚀 Getting Started

### Prerequisites

[Foundry](https://book.getfoundry.sh/getting-started/installation) installed

### Clone & Install
```
git clone https://github.com/BuildsWithKing/BuildsWithKing-KingSecurity.git
cd BuildsWithKing-KingSecurity
forge install
```
### Build & Test
```
forge build
forge test -vvv
```
---

## ⚡Installation: 

Install this package into your Foundry/Hardhat project by adding it as a Git submodule or using forge install:

```solidity
forge install BuildsWithKing/buildswithking-security
```
Then import module with:

```solidity
import {Kingable} from "buildswithking-security/contracts/access/core/Kingable.sol";
```
---

## 🛠️ Usage

To inherit `Kingable` in your contract:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Kingable} from "buildswithking-security/contracts/access/core/Kingable.sol";

contract MyDapp is Kingable {
    constructor(address _kingAddress) Kingable(_kingAddress) {}

    function doKingStuff() external onlyKing {
        // only the King can call this
    }
}
```

## 🛡 Security Considerations

This repo is a security primitives library, not a production protocol.

Audit your integration when using these contracts in live deployments.

Includes custom errors and reverts for gas savings and safety.



---

## ✍ Author

Michealking (@BuildsWithKing)

Solidity Smart Contract Developer

Security-focused, building transparent protocols

📧 buildswithking@gmail.com


---

## 📜 License

This project is licensed under the MIT License.

---