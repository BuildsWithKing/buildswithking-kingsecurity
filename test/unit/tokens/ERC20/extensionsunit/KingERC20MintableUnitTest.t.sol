// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20MintableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *     KingERC20Mintable unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, IERC20, KingERC20Mintable, KingERC20MintableMockTest contracts.
import {BaseTest} from "../../../BaseTest.t.sol";
import {IERC20} from "../../../../../src/tokens/ERC20/interfaces/IERC20.sol";
import {KingERC20Mintable} from "../../../../../src/tokens/ERC20/extensions/KingERC20Mintable.sol";
import {KingAccessControlLite} from "../../../../../src/core/KingAccessControlLite.sol";
import {KingERC20Errors} from "../../../../../src/tokens/errors/KingERC20Errors.sol";
import {KingERC20MintableMockTest} from "../../../../mocks/KingERC20MintableMockTest.t.sol";

contract KingERC20MintableUnitTest is BaseTest {
    // -------------------------------------------- Unit Test: King's Write Functions ---------------------------------
    /// @notice Test to ensure the king can assign a minter.
    function testAssignMinter_Succeeds() public {
        // Emit the event MinterAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterAssigned(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Assert s_minter is equal to minter.
        assertEq(kingERC20Mintable.s_minter(), MINTER);
    }

    /// @notice Test to ensure king can't assign same minter twice.
    function testAssignMinter_ReturnsForSameMinter() public {
        // Emit the event MinterAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterAssigned(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Return since minter is the current minter.
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Assert s_minter is equal to minter.
        assertEq(kingERC20Mintable.s_minter(), MINTER);
    }

    /// @notice Test to ensure only the king can assign the minter role.
    function testAssignMinter_RevertsUnauthorized() public {
        // Revert since minter is not the king.
        vm.expectRevert(
            abi.encodeWithSelector(
                KingAccessControlLite.Unauthorized.selector, MINTER, kingAccessControlLite.KING_ROLE()
            )
        );
        vm.prank(MINTER);
        kingERC20Mintable.assignMinter(MINTER);
    }

    /// @notice Test to ensure the king can remove the minter role from a minter.
    function testRemoveMinter_Succeeds() public {
        // Emit the event MinterRemoved and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterRemoved(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.removeMinter(MINTER);

        // Assert s_minter is equal to ZERO.
        assertEq(kingERC20Mintable.s_minter(), ZERO);
    }

    /// @notice Test to ensure the king can't remove role from same minter twice.
    function testRemoveMinter_ReturnsForSameMinter() public {
        // Emit the event MinterAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterAssigned(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Emit the event MinterRemoved and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterRemoved(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.removeMinter(MINTER);

        // Return since the minter no longer holds the minter role.
        vm.prank(KING);
        kingERC20Mintable.removeMinter(MINTER);

        // Assert s_minter is equal to ZERO.
        assertEq(kingERC20Mintable.s_minter(), ZERO);
    }

    /// @notice Test to ensure only the king can remove the minter role.
    function testRemoveMinter_RevertsUnauthorized() public {
        // Revert since the minter is not the king.
        vm.expectRevert(
            abi.encodeWithSelector(
                KingAccessControlLite.Unauthorized.selector, MINTER, kingAccessControlLite.KING_ROLE()
            )
        );
        vm.prank(MINTER);
        kingERC20Burnable.removeBurner(MINTER);
    }

    // ------------------------------ Unit Test: King and Minter's Write Functions -----------------------
    /// @notice Test to ensure the king and minter can mint the token.
    function testMint_Succeeds() public {
        // Assign twoMillion.
        uint256 twoMillion = 2000000;

        // Emit the event MinterAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterAssigned(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Prank as the minter
        vm.prank(MINTER);
        kingERC20Mintable.mint(KING, ONE_MILLION);

        // Assert the token's total supply is equal to 2,000,000.
        assertEq(kingERC20Mintable.totalSupply(), twoMillion);
    }

    // -------------------------------------------------- Unit Test: External Write Function ------------------------------------
    /// @notice Test to ensure the minter can renounce the minter role using the external write function.
    function testRenounceRole_Succeeds() public {
        // Emit the event MinterAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Mintable.MinterAssigned(KING, MINTER);
        vm.prank(KING);
        kingERC20Mintable.assignMinter(MINTER);

        // Prank and renounce the minter role as the minter.
        vm.prank(MINTER);
        kingERC20Mintable.renounceRole(kingERC20Mintable.MINTER_ROLE());

        // Assert the minter no longer has the minter's role.
        assertEq(kingAccessControlLite.hasRole(kingERC20Mintable.MINTER_ROLE(), MINTER), false);
    }
}
