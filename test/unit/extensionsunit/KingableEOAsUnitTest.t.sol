// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableEOAsUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 13th of Sept, 2025.
 *
 *     KingableEOAs unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, KingableEOAs, KingableEOAsMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingableEOAs} from "../../../src/extensions/KingableEOAs.sol";
import {KingableEOAsMockTest} from "../../mocks/KingableEOAsMockTest.t.sol";

contract KingableEOAsUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. -----------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() public view {
        // Assign _currentKing.
        address _currentKing = kingableEOAs.currentKing();

        // Assert both are equal.
        assertEq(KING, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(ZERO, KING);
        kingableEOAs = new KingableEOAsMockTest(KING);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, ZERO));
        kingableEOAs = new KingableEOAsMockTest(ZERO);
    }

    /// @notice Test to ensure contract addresses reverts.
    function testContractAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if a contract address is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, CONTRACTKING));
        kingableEOAs = new KingableEOAsMockTest(CONTRACTKING);
    }

    // ----------------------------------------------------- King's test write functions. -----------------------------

    /// @notice Test to ensure KING can transfer kingship.
    function testTransferKingship_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(KING, NEWKING);
        kingableEOAs.transferKingshipTo(NEWKING);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, KING, NEWKING));
        vm.prank(KING);
        kingableEOAs.transferKingshipTo(NEWKING);
    }

    /// @notice Test to ensure KING can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() public {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.SameKing.selector, KING));
        vm.prank(KING);
        kingableEOAs.transferKingshipTo(KING);

        // Assert current king is still KING.
        assertEq(kingableEOAs.currentKing(), KING);
    }

    /// @notice Test to ensure king can't transfer kingship to contract address.
    function testTransferKingship_RevertsIfContractAddress() public {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, CONTRACTKING));
        vm.prank(KING);
        kingableEOAs.transferKingshipTo(CONTRACTKING);

        // Assert current king is still KING.
        assertEq(kingableEOAs.currentKing(), KING);
    }

    /// @notice Test to ensure only king can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingableEOAs.transferKingshipTo(NEWKING);

        // Assert current king is still KING.
        assertEq(kingableEOAs.currentKing(), KING);
    }

    /// @notice Test to ensure king can renounce kingship.
    function testRenounceKingship_Succeeds() public {
        // Prank as king.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(KING, ZERO);
        kingableEOAs.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, KING, ZERO));
        vm.prank(KING);
        kingableEOAs.renounceKingship();

        // Assert address ZERO is new king.
        assertEq(kingableEOAs.currentKing(), ZERO);
    }

    // --------------------------------------------------- Users test read functions. --------------------------------------

    /// @notice Test to ensure isKing returns `true` or `false`.
    function testIsKing() public view {
        // Assign isKing.
        bool isKing = kingableEOAs.isKing(ZERO);
        bool king = kingableEOAs.isKing(KING);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
