// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingPausableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 23rd of Sept, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingPausable contract.
import {KingPausable} from "../../src/extensions/KingPausable.sol";

contract KingPausableMockTest is KingPausable {
    // --------------------------------------- Constructor ----------------------------

    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingPausable(_kingAddress) {}
}
