// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20PausableMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingERC20Pausable contract.
import {KingERC20Pausable} from "../../src/tokens/ERC20/extensions/KingERC20Pausable.sol";

contract KingERC20PausableMockTest is KingERC20Pausable {
    // --------------------------------------- Constructor --------------------------------------
    /// @notice Assigns the king, and token's information at deployment.
    /// @dev Sets the king, token's name, symbol, initial supply at deployment. Mints the initial supply to the king upon deployment.
    /// @param king_ The king's address.
    /// @param name_ The token's name.
    /// @param symbol_ The token's symbol.
    /// @param initialSupply_ The token's initial supply.
    constructor(address king_, string memory name_, string memory symbol_, uint256 initialSupply_)
        KingERC20Pausable(king_, name_, symbol_, initialSupply_)
    {}
}
