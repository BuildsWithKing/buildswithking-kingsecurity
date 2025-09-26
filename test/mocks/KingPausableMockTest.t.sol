// SPDX-License-Identifier: MIT

/// @title KingPausableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 23rd Of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingPausable contract.
import {KingPausable} from "../../src/extensions/KingPausable.sol";

contract KingPausableMockTest is KingPausable {
    // --------------------------------------- Constructor ----------------------------

    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingPausable(_kingAddress) {}
}
