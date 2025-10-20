// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingablePausableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingablePausable contract.
import {KingablePausable} from "../../src/extensions/KingablePausable.sol";

contract KingablePausableMockTest is KingablePausable {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingablePausable(_kingAddress) {}
}
