// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingAccessControlLiteUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 5th of Nov, 2025.
 *
 *     KingAccessControlLite unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, KingAccessControlLite, KingAccessControlLiteMockTest contracts.
import {BaseTest} from "../BaseTest.t.sol";
import {KingAccessControlLite} from "../../../src/core/KingAccessControlLite.sol";
import {KingAccessControlLiteMockTest} from "../../mocks/KingAccessControlLiteMockTest.t.sol";

contract KingAccessControlLiteUnitTest is BaseTest {
    // ------------------------------------------------------- Unit Test: King's Write Functions ---------------------------
    /// @notice Test to ensure the king can transfer the king role.
    function testTransferKingRole_Succeeds() public {
        // Emit the events RoleRevoked and RoleGranted.
        vm.expectEmit(true, true, true, false);
        emit KingAccessControlLite.RoleRevoked(KING, kingAccessControlLite.KING_ROLE(), KING);
        emit KingAccessControlLite.RoleGranted(KING, kingAccessControlLite.KING_ROLE(), NEWKING);

        // Prank and transfer king role as the King.
        vm.prank(KING);
        kingAccessControlLite.transferKingRole(NEWKING);

        // Revert since the old king is no longer the king.
        vm.expectRevert();
        vm.prank(KING);
        kingAccessControlLite.transferKingRole(NEWKING);

        // Assert the new king now has the king role.
        assertEq(kingAccessControlLite.hasRole(kingAccessControlLite.KING_ROLE(), NEWKING), true);
    }

    /// @notice Test to ensure the king can't transfer role to self.
    function testTransferKingRole_ReturnsForSameKing() public {
        // Return since the old king is the same as the new king.
        vm.prank(KING);
        kingAccessControlLite.transferKingRole(KING);

        // Assert the king still has the king role.
        assertEq(kingAccessControlLite.hasRole(kingAccessControlLite.KING_ROLE(), KING), true);
    }

    /// @notice Test to ensure only the king can transfer the king role.
    function testTransferKingRole_RevertsUnathorized() public {
        // Revert since user2 isn't the king.
        vm.expectRevert(
            abi.encodeWithSelector(
                KingAccessControlLite.Unauthorized.selector, USER2, kingAccessControlLite.KING_ROLE()
            )
        );
        vm.prank(USER2);
        kingAccessControlLite.transferKingRole(USER2);
    }

    // -------------------------------------------------- Unit Test: External Write Function ------------------------------------
    /// @notice Test to ensure the king can't renounce the king role using the external write function.
    function testRenounceRole_ReturnsForKingRole() public {
        // Prank and renounce the king role as the king.
        vm.prank(KING);
        kingAccessControlLite.renounceRole(kingAccessControlLite.KING_ROLE());

        // Assert the king is still the current king and still has the king role.
        assertEq(kingAccessControlLite.hasRole(kingAccessControlLite.KING_ROLE(), KING), true);
    }
}
