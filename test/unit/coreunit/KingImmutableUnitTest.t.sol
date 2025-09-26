// SPDX-License-Identifier: MIT

/// @title KingImmutableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *     KingImmutable unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, KingImmutable, KingImmutableMockTest contracts.
import {BaseTest} from "../BaseTest.t.sol";
import {KingImmutable} from "../../../src/core/KingImmutable.sol";
import {KingImmutableMockTest} from "../../mocks/KingImmutableMockTest.t.sol";

contract KingImmutableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. -----------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingImmutable.currentKing();

        // Assert both are equal.
        assertEq(_king, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipDeclared event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipDeclared`.
        vm.expectEmit(true, false, false, false);
        emit KingImmutable.KingshipDeclared(_king);
        kingImmutable = new KingImmutableMockTest(_king);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingImmutable.InvalidKing.selector, _zero));
        kingImmutable = new KingImmutableMockTest(_zero);
    }

    // ----------------------------------------------- Test for Users write functions ----------------------------------
    /// @notice Test to ensure currentKing returns king's address.
    function testCurrentKing_Returns() external view {
        // Assign currentKing.
        address currentKing = kingImmutable.currentKing();

        // Assert both are equal.
        assertEq(currentKing, _king);
    }

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing_Returns() external {
        // Prank as _king.
        vm.startPrank(_king);

        // Assign isKing and king.
        bool isKing = kingImmutable.isKing(_king);
        bool king = kingImmutable.isKing(_contractKing);

        // Stop prank.
        vm.stopPrank();

        // Assert both are equal.
        assertEq(isKing, true);
        assertEq(king, false);
    }

    /// @notice test to ensure onlyKing modifier reverts unauthorized.
    function testIsKing_RevertsUnauthorized() external {
        vm.expectRevert(abi.encodeWithSelector(KingImmutable.Unauthorized.selector, _user2, _king));
        // Prank as user2.
        vm.prank(_user2);
        kingImmutable.isKing(_contractKing);
    }
}
