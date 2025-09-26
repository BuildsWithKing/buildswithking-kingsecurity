// SPDX-License-Identifier: MIT

/// @title KingableEOAsUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 13th Of Sept, 2025.
 *
 *     KingableEOAs unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, KingableEOAs, KingableEOAsMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingableEOAs} from "../../../src/extensions/KingableEOAs.sol";
import {KingableEOAsMockTest} from "../../mocks/KingableEOAsMockTest.t.sol";

contract KingableEOAsUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. -----------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingableEOAs.currentKing();

        // Assert both are equal.
        assertEq(_king, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(_zero, _king);
        kingableEOAs = new KingableEOAsMockTest(_king);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, _zero));
        kingableEOAs = new KingableEOAsMockTest(_zero);
    }

    /// @notice Test to ensure contract addresses reverts.
    function testContractAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if a contract address is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, _contractKing));
        kingableEOAs = new KingableEOAsMockTest(_contractKing);
    }

    // ----------------------------------------------------- King's test write functions. -----------------------------

    /// @notice Test to ensure king can transfer kingship.
    function testTransferKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(_king, _newKing);
        kingableEOAs.transferKingshipTo(_newKing);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _king, _newKing));
        vm.prank(_king);
        kingableEOAs.transferKingshipTo(_newKing);
    }

    /// @notice Test to ensure king can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() external {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.SameKing.selector, _king));
        vm.prank(_king);
        kingableEOAs.transferKingshipTo(_king);

        // Assert current king is still _king.
        assertEq(kingableEOAs.currentKing(), _king);
    }

    /// @notice Test to ensure king can't transfer kingship to contract address.
    function testTransferKingship_RevertsIfContractAddress() external {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, _contractKing));
        vm.prank(_king);
        kingableEOAs.transferKingshipTo(_contractKing);

        // Assert current king is still _king.
        assertEq(kingableEOAs.currentKing(), _king);
    }

    /// @notice Test to ensure only king can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingableEOAs.transferKingshipTo(_newKing);

        // Assert current king is still _king.
        assertEq(kingableEOAs.currentKing(), _king);
    }

    /// @notice Test to ensure king can renounce kingship.
    function testRenounceKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(_king, _zero);
        kingableEOAs.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _king, _zero));
        vm.prank(_king);
        kingableEOAs.renounceKingship();

        // Assert address zero is new king.
        assertEq(kingableEOAs.currentKing(), _zero);
    }

    // --------------------------------------------------- Users test read functions. --------------------------------------

    /// @notice Test to ensure isKing returns `true` or `false`.
    function testIsKing() external view {
        // Assign isKing.
        bool isKing = kingableEOAs.isKing(_zero);
        bool king = kingableEOAs.isKing(_king);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
