// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20CappedMockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingERC20Capped and KingERC20 contract.
import {KingERC20Capped} from "../../src/tokens/ERC20/extensions/KingERC20Capped.sol";
import {KingERC20} from "../../src/tokens/ERC20/KingERC20.sol";

contract KingERC20CappedMockTest is KingERC20Capped {
    // --------------------------------------- Constructor --------------------------------------
    /// @notice Assigns the king, and token's information at deployment.
    /// @dev Sets the king, token's name, symbol, initial supply at deployment. Mints the initial supply to the king upon deployment.
    /// @param king_ The king's address.
    /// @param name_ The token's name.
    /// @param symbol_ The token's symbol.
    /// @param initialSupply_ The token's initial supply.
    /// @param cap_ The token's capped supply.
    constructor(address king_, string memory name_, string memory symbol_, uint256 initialSupply_, uint256 cap_)
        KingERC20(king_, name_, symbol_, initialSupply_)
        KingERC20Capped(cap_)
    {}
}
