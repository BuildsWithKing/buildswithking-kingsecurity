// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableContractsMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 23rd of Sept, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingableContracts.
import {KingableContracts} from "../../src/extensions/KingableContracts.sol";

contract KingableContractsMockTest is KingableContracts {
    // --------------------------------------- Constructor ------------------------------
    /// @dev Sets initial king.
    /// @param _kingAddress The initial king's address.
    constructor(address _kingAddress) KingableContracts(_kingAddress) {}
}
