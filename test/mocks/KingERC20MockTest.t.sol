// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20MockTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *  @dev Creating mocks for abstract contracts is the best and professional practice.
 */

/// @notice Imports KingERC20 contract.
import {KingERC20} from "../../src/tokens/ERC20/KingERC20.sol";

contract KingERC20MockTest is KingERC20 {
    // --------------------------------------- Constructor --------------------------------------
    /// @notice Assigns the king, and token's information at deployment.
    /// @dev Sets the king, token's name, symbol, initial supply at deployment. Mints the initial supply to the king upon deployment.
    /// @param king_ The king's address.
    /// @param name_ The token's name.
    /// @param symbol_ The token's symbol.
    /// @param initialSupply_ The token's initial supply.
    constructor(address king_, string memory name_, string memory symbol_, uint256 initialSupply_)
        KingERC20(king_, name_, symbol_, initialSupply_)
    {}
}
