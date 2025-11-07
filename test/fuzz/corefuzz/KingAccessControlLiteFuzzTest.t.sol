// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingAccessControlLiteFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 7th of Nov, 2025.
 *
 *      KingAccessControlLite fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingAccessControlLiteUnitTest, and KingAccessControlLite contract.
import {KingAccessControlLiteUnitTest} from "../../unit/coreunit/KingAccessControlLiteUnitTest.t.sol";
import {KingAccessControlLite} from "../../../src/core/KingAccessControlLite.sol";

contract KingAccessControlLiteFuzzTest is KingAccessControlLiteUnitTest {
    // ------------------------------------------ Fuzz Test: TransferKingRole ------------------------------------
    /// @notice Fuzz test Transfer king role succeeds.
    /// @param randomKing_ The random king's address.
    function testFuzz_TransferKingRole_Succeeds(address randomKing_) public {
        // Assume: Random king's address is not the zero, the king, or the contract address.
        vm.assume(randomKing_ != address(0) && randomKing_ != KING && randomKing_ != address(kingAccessControlLite));

        // Prank and transfer the king role as the king.
        vm.prank(KING);
        kingAccessControlLite.transferKingRole(randomKing_);

        // Assert the randomking_ now has the king role.
        assertEq(kingAccessControlLite.hasRole(kingAccessControlLite.KING_ROLE(), randomKing_), true);
    }

    // ------------------------------------------- Fuzz Test: Has Role ----------------------------------------------
    /// @notice Fuzz test Has role returns.
    /// @param randomAddress_ The random addresses.
    function testFuzz_HasRole_Returns(address randomAddress_) public {
        // Assume: The random addresses is not the zero, the king, or the contract address.
        vm.assume(
            randomAddress_ != address(0) && randomAddress_ != KING && randomAddress_ != address(kingAccessControlLite)
        );

        // Assert randomAddress_ doesn't have the king role.
        assertEq(kingAccessControlLite.hasRole(kingAccessControlLite.KING_ROLE(), randomAddress_), false);
    }
}
