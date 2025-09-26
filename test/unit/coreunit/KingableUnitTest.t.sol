// SPDX-License-Identifier: MIT

/// @title KingableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *     Kingable unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, Kingable, KingableMockTest contracts.
import {BaseTest} from "../BaseTest.t.sol";
import {Kingable} from "../../../src/core/Kingable.sol";
import {KingableMockTest} from "../../mocks/KingableMockTest.t.sol";

contract KingableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. -----------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingable.currentKing();

        // Assert both are equal.
        assertEq(_king, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_zero, _king);
        kingable = new KingableMockTest(_king);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, _zero));
        kingable = new KingableMockTest(_zero);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_zero, _contractKing);
        kingable = new KingableMockTest(_contractKing);
    }

    // ----------------------------------------------------- Test for King's write functions. -----------------------------

    /// @notice Test to ensure king can transfer kingship.
    function testTransferKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_king, _newKing);
        kingable.transferKingshipTo(_newKing);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, _king, _newKing));
        vm.prank(_king);
        kingable.transferKingshipTo(_newKing);

        // Assert _newKing is king.
        assertEq(kingable.currentKing(), _newKing);
    }

    /// @notice Test to ensure king can transfer kingship to contract address.
    function testTransferKingship_SucceedsIfContractAddress() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_king, _contractKing);
        kingable.transferKingshipTo(_contractKing);

        // Assert _contractKing is new _king.
        assertEq(kingable.currentKing(), _contractKing);
    }

    /// @notice Test to ensure king can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() external {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.SameKing.selector, _king));
        vm.prank(_king);
        kingable.transferKingshipTo(_king);

        // Assert current king is still _king.
        assertEq(kingable.currentKing(), _king);
    }

    /// @notice Test to ensure king can't transfer kingship to address zero.
    function testTransferKingship_RevertsInvalidKing() external {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, _zero));
        vm.prank(_king);
        kingable.transferKingshipTo(_zero);

        // Assert current king is still _king.
        assertEq(kingable.currentKing(), _king);
    }

    /// @notice Test to ensure only king can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingable.transferKingshipTo(_newKing);

        // Assert current king is still _king.
        assertEq(kingable.currentKing(), _king);
    }

    /// @notice Test to ensure king can renounce kingship.
    function testRenounceKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipRenounced(_king, _zero);
        kingable.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, _king, _zero));
        vm.prank(_king);
        kingable.renounceKingship();

        // Assert address zero is new king.
        assertEq(kingable.currentKing(), _zero);
    }

    // --------------------------------------------------- Test for Users read function. --------------------------------------

    /// @notice Test to ensure isKing returns `true` or `false`.
    function testIsKing() external view {
        // Assign isKing.
        bool isKing = kingable.isKing(_zero);
        bool king = kingable.isKing(_king);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
