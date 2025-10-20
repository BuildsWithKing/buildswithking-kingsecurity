// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingImmutableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingImmutable contract.
import {KingImmutable} from "../../src/core/KingImmutable.sol";

contract KingImmutableMockTest is KingImmutable {
    // --------------------------------------- Constructor -------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingImmutable(_kingAddress) {}
}
