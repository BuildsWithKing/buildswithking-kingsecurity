// SPDX-License-Identifier: MIT

/// @title KingableEOAsMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 13th Of Sept, 2025.
 *
 *  Creating mocks for abstract contracts is the best and professional practice.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingableEOAs contract.
import {KingableEOAs} from "../../src/extensions/KingableEOAs.sol";

contract KingableEOAsMockTest is KingableEOAs {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingableEOAs(_kingAddress) {}
}
