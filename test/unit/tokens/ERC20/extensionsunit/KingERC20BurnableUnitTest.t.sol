// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20BurnableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *     KingERC20Burnable unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, IERC20, KingERC20Burnable, KingERC20BurnableMockTest contracts.
import {BaseTest} from "../../../BaseTest.t.sol";
import {IERC20} from "../../../../../src/tokens/ERC20/interfaces/IERC20.sol";
import {KingERC20Burnable} from "../../../../../src/tokens/ERC20/extensions/KingERC20Burnable.sol";
import {KingAccessControlLite} from "../../../../../src/core/KingAccessControlLite.sol";
import {KingERC20Errors} from "../../../../../src/tokens/errors/KingERC20Errors.sol";
import {KingERC20BurnableMockTest} from "../../../../mocks/KingERC20BurnableMockTest.t.sol";

contract KingERC20BurnableUnitTest is BaseTest {
    // -------------------------------------------- Unit Test: King's Write Functions ---------------------------------
    /// @notice Test to ensure the king can assign a burner.
    function testAssignBurner_Succeeds() public {
        // Emit the event BurnerAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerAssigned(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Assert s_burner is equal to burner.
        assertEq(kingERC20Burnable.s_burner(), BURNER);
    }

    /// @notice Test to ensure king can't assign same burner twice.
    function testAssignBurner_ReturnsForSameBurner() public {
        // Emit the event BurnerAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerAssigned(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Return since burner is the current burner.
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Assert s_burner is equal to burner.
        assertEq(kingERC20Burnable.s_burner(), BURNER);
    }

    /// @notice Test to ensure only the king can assign the burner role.
    function testAssignBurner_RevertsUnauthorized() public {
        // Revert since burner is not the king.
        vm.expectRevert(
            abi.encodeWithSelector(
                KingAccessControlLite.Unauthorized.selector, BURNER, kingAccessControlLite.KING_ROLE()
            )
        );
        vm.prank(BURNER);
        kingERC20Burnable.assignBurner(BURNER);
    }

    /// @notice Test to ensure the king can remove the burner role from a burner.
    function testRemoveBurner_Succeeds() public {
        // Emit the event BurnerRemoved and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerRemoved(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.removeBurner(BURNER);

        // Assert s_burner is equal to ZERO.
        assertEq(kingERC20Burnable.s_burner(), ZERO);
    }

    /// @notice Test to ensure the king can't remove role from same burner twice.
    function testRemoveBurner_ReturnsForSameBurner() public {
        // Emit the event BurnerAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerAssigned(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Emit the event BurnerRemoved and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerRemoved(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.removeBurner(BURNER);

        // Return since the burner no longer holds the burner role.
        vm.prank(KING);
        kingERC20Burnable.removeBurner(BURNER);

        // Assert s_burner is equal to ZERO.
        assertEq(kingERC20Burnable.s_burner(), ZERO);
    }

    /// @notice Test to ensure only the king can remove the burner role.
    function testRemoveBurner_RevertsUnauthorized() public {
        // Revert since burner is not the king.
        vm.expectRevert(
            abi.encodeWithSelector(
                KingAccessControlLite.Unauthorized.selector, BURNER, kingAccessControlLite.KING_ROLE()
            )
        );
        vm.prank(BURNER);
        kingERC20Burnable.removeBurner(BURNER);
    }

    // ------------------------------ Unit Test: King and Burner's Write Functions -----------------------
    /// @notice Test to ensure the king and burner can burn the token.
    function testBurnFrom_Succeeds() public {
        // Emit the event BurnerAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerAssigned(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Prank as the burner
        vm.prank(BURNER);
        kingERC20Burnable.burnFrom(KING, ONE_MILLION);

        // Assert the token's total supply is equal to zero.
        assertEq(kingERC20Burnable.totalSupply(), 0);
    }

    /// @notice Test to ensure the burner can't burn token of users with zero balance.
    function testBurnFrom_RevertsInsufficientBalance() public {
        // Emit the event BurnerAssigned and prank as the king.
        vm.expectEmit(true, true, false, false);
        emit KingERC20Burnable.BurnerAssigned(KING, BURNER);
        vm.prank(KING);
        kingERC20Burnable.assignBurner(BURNER);

        // Revert since User2 has zero token balance.
        vm.expectRevert(
            abi.encodeWithSelector(KingERC20Errors.InsufficientBalance.selector, kingERC20Burnable.balanceOf(USER2))
        );
        vm.prank(BURNER);
        kingERC20Pausable.burnFrom(USER2, ONE_THOUSAND);
    }

    /// @notice Test to ensure only the king and burner can `burnFrom` token.
    function testBurnFrom_RevertsUnauthorized() public {
        // Revert since user1 is not the king or the burner.
        vm.expectRevert(
            abi.encodeWithSelector(KingAccessControlLite.Unauthorized.selector, USER1, kingERC20Burnable.BURNER_ROLE())
        );
        vm.prank(USER1);
        kingERC20Burnable.burnFrom(KING, ONE_MILLION);
    }

    // ----------------------------------------------- Unit Test: Write Function ----------------------------------------
    /// @notice Test to ensure users can burn their token.
    function testBurn_Succeeds() public {
        // Assign nineHundredAndNinetyNineThousand.
        uint64 nineHundredAndNinetyNineThousand = 999000;

        // Prank as the king.
        vm.prank(KING);
        kingERC20Burnable.burn(ONE_THOUSAND);

        // Assert the token's total supply is equal to 999000.
        assertEq(kingERC20Burnable.totalSupply(), nineHundredAndNinetyNineThousand);
    }

    /// @notice Test to ensure users with zero balance can't burn token.
    function testBurn_RevertsInsufficientBalance() public {
        // Revert since user2 has zero token balance.
        vm.expectRevert(
            abi.encodeWithSelector(KingERC20Errors.InsufficientBalance.selector, kingERC20Burnable.balanceOf(USER2))
        );
        vm.prank(USER2);
        kingERC20Burnable.burn(ONE_THOUSAND);
    }
}
