// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports Kingable contract.
import {Kingable} from "../../src/core/Kingable.sol";

contract KingableMockTest is Kingable {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) Kingable(_kingAddress) {}
}
