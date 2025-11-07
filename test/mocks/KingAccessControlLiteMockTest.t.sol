// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingAccessControlLiteMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 5th of Nov, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingAccessControlLite contract.
import {KingAccessControlLite} from "../../src/core/KingAccessControlLite.sol";

contract KingAccessControlLiteMockTest is KingAccessControlLite {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets king.
    /// @param king_ The initial king's address.
    constructor(address king_) KingAccessControlLite(king_) {}
}
