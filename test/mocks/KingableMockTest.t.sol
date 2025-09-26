// SPDX-License-Identifier: MIT

/// @title KingableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */
pragma solidity ^0.8.30;

/// @notice Imports Kingable contract.
import {Kingable} from "../../src/core/Kingable.sol";

contract KingableMockTest is Kingable {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) Kingable(_kingAddress) {}
}
