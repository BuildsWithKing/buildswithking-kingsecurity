// SPDX-License-Identifier: MIT

/// @title KingablePausableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingablePausable contract.
import {KingablePausable} from "../../src/extensions/KingablePausable.sol";

contract KingablePausableMockTest is KingablePausable {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingablePausable(_kingAddress) {}
}
