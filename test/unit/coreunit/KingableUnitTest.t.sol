// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *     Kingable unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, Kingable, KingableMockTest contracts.
import {BaseTest} from "../BaseTest.t.sol";
import {Kingable} from "../../../src/core/Kingable.sol";
import {KingableMockTest} from "../../mocks/KingableMockTest.t.sol";

contract KingableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. -----------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() public view {
        // Assign _currentKing.
        address _currentKing = kingable.currentKing();

        // Assert both are equal.
        assertEq(KING, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(ZERO, KING);
        kingable = new KingableMockTest(KING);
    }

    /// @notice Test to ensure address ZERO reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if address ZERO is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, ZERO));
        kingable = new KingableMockTest(ZERO);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(ZERO, CONTRACTKING);
        kingable = new KingableMockTest(CONTRACTKING);
    }

    // ----------------------------------------------------- Test for King's write functions. -----------------------------

    /// @notice Test to ensure KING can transfer kingship.
    function testTransferKingship_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(KING, NEWKING);
        kingable.transferKingshipTo(NEWKING);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, KING, NEWKING));
        vm.prank(KING);
        kingable.transferKingshipTo(NEWKING);

        // Assert NEWKING is king.
        assertEq(kingable.currentKing(), NEWKING);
    }

    /// @notice Test to ensure KING can transfer kingship to contract address.
    function testTransferKingship_SucceedsIfContractAddress() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(KING, CONTRACTKING);
        kingable.transferKingshipTo(CONTRACTKING);

        // Assert CONTRACTKING is new KING.
        assertEq(kingable.currentKing(), CONTRACTKING);
    }

    /// @notice Test to ensure KING can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() public {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.SameKing.selector, KING));
        vm.prank(KING);
        kingable.transferKingshipTo(KING);

        // Assert current king is still KING.
        assertEq(kingable.currentKing(), KING);
    }

    /// @notice Test to ensure KING can't transfer kingship to address ZERO.
    function testTransferKingship_RevertsInvalidKing() public {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, ZERO));
        vm.prank(KING);
        kingable.transferKingshipTo(ZERO);

        // Assert current king is still KING.
        assertEq(kingable.currentKing(), KING);
    }

    /// @notice Test to ensure only KING can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingable.transferKingshipTo(NEWKING);

        // Assert current king is still KING.
        assertEq(kingable.currentKing(), KING);
    }

    /// @notice Test to ensure KING can renounce kingship.
    function testRenounceKingship_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipRenounced(KING, ZERO);
        kingable.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, KING, ZERO));
        vm.prank(KING);
        kingable.renounceKingship();

        // Assert address zero is new king.
        assertEq(kingable.currentKing(), ZERO);
    }

    // --------------------------------------------------- Test for Users read function. --------------------------------------

    /// @notice Test to ensure isKing returns `true` or `false`.
    function testIsKing() public view {
        // Assign isKing.
        bool isKing = kingable.isKing(ZERO);
        bool king = kingable.isKing(KING);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
