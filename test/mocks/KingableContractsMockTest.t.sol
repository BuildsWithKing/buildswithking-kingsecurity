// SPDX-License-Identifier: MIT

/// @title KingableContractsMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 23rd Of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingableContracts.
import {KingableContracts} from "../../src/extensions/KingableContracts.sol";

contract KingableContractsMockTest is KingableContracts {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingableContracts(_kingAddress) {}
}
