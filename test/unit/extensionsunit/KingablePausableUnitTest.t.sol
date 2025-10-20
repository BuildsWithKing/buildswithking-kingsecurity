// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title  KingablePausableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *     KingablePausable unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, KingablePausable, KingablePausableMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingablePausable} from "../../../src/extensions/KingablePausable.sol";
import {KingablePausableMockTest} from "../../mocks/KingablePausableMockTest.t.sol";

contract KingablePausableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ---------------------------------
    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() public view {
        // Assign _currentKing.
        address _currentKing = kingablePausable.currentKing();

        // Assert both are equal.
        assertEq(KING, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(ZERO, KING);
        kingablePausable = new KingablePausableMockTest(KING);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if address ZERO is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.InvalidKing.selector, ZERO));
        kingablePausable = new KingablePausableMockTest(ZERO);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(ZERO, CONTRACTKING);
        kingablePausable = new KingablePausableMockTest(CONTRACTKING);
    }

    // -------------------------------------------------------- Test for king's write functions -----------------------------------
    /// @notice Test to ensure KING can transfer kingship.
    function testTransferKingship_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(KING, NEWKING);
        kingablePausable.transferKingshipTo(NEWKING);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, KING, NEWKING));
        vm.prank(KING);
        kingablePausable.transferKingshipTo(NEWKING);
    }

    /// @notice Test to ensure KING can transfer kingship to contract address.
    function testTransferKingship_SucceedsIfContractAddress() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(KING, CONTRACTKING);
        kingablePausable.transferKingshipTo(CONTRACTKING);

        // Assert CONTRACTKING is new KING.
        assertEq(kingablePausable.currentKing(), CONTRACTKING);
    }

    /// @notice Test to ensure KING can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() public {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.SameKing.selector, KING));
        vm.prank(KING);
        kingablePausable.transferKingshipTo(KING);

        // Assert current king is still KING.
        assertEq(kingablePausable.currentKing(), KING);
    }

    /// @notice Test to ensure KING can't transfer kingship to address zero.
    function testTransferKingship_RevertsInvalidKing() public {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.InvalidKing.selector, ZERO));
        vm.prank(KING);
        kingablePausable.transferKingshipTo(ZERO);

        // Assert current king is still KING.
        assertEq(kingablePausable.currentKing(), KING);
    }

    /// @notice Test to ensure only KING can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingablePausable.transferKingshipTo(NEWKING);

        // Assert current king is still KING.
        assertEq(kingablePausable.currentKing(), KING);
    }

    /// @notice Test to ensure KING can renounce kingship.
    function testRenounceKingship_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipRenounced(KING, ZERO);
        kingablePausable.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, KING, ZERO));
        vm.prank(KING);
        kingablePausable.renounceKingship();
    }

    /// @notice Test to ensure KING can pause and then activate contract.
    function testActivateContract_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(KING);
        kingablePausable.pauseContract();

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractActivated(KING);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure KING can't activate contract once it's active.
    function testActivateContract_RevertsAlreadyActive() public {
        // Revert `AlreadyActive`.
        vm.expectRevert(KingablePausable.AlreadyActive.selector);
        vm.prank(KING);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure only KING can activate contract.
    function testActivateContract_RevertsUnauthorized() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure KING can pause contract.
    function testPauseContract_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(KING);
        kingablePausable.pauseContract();
    }

    /// @notice Test to ensure KING can't pause contract once it's paused.
    function testPauseContract_RevertsAlreadyPaused() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(KING);
        kingablePausable.pauseContract();

        // Revert `AlreadyPaused`.
        vm.expectRevert(KingablePausable.AlreadyPaused.selector);
        vm.prank(KING);
        kingablePausable.pauseContract();
    }

    /// @notice Test to ensure only KING can pause contract.
    function testPauseContract_RevertsUnauthorized() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingablePausable.pauseContract();
    }

    // ----------------------------------------------------- Test for users public functions ---------------------------------------
    /// @notice Test to ensure users can check contract state.
    function testIsContractActive_Returns() public {
        // Prank as USER2.
        vm.prank(USER2);
        // Assign state.
        bool state = kingablePausable.isContractActive();

        // Assert contract state is active (true).
        assertEq(state, true);
    }

    /// @notice Test to ensure users can't perform transactions once paused.
    function testIsContractActive_RevertsPausedContract() public {
        // Prank as KING
        vm.prank(KING);
        kingablePausable.pauseContract();

        // Revert `PausedContract`.
        vm.expectRevert(KingablePausable.PausedContract.selector);
        vm.prank(USER2);
        kingablePausable.isContractActive();
    }

    /// @notice Test to ensure currentKing returns king's address.
    function testCurrentKing_Returns() public view {
        // Assign currentKing.
        address currentKing = kingablePausable.currentKing();

        // Assert both are equal.
        assertEq(currentKing, KING);
    }

    /// @notice Test to ensure isKing returns `true` or `false`.
    function testIsKing_Returns() public view {
        // Assign isKing.
        bool isKing = kingablePausable.isKing(KING);
        bool king = kingablePausable.isKing(CONTRACTKING);

        // Assert both are equal.
        assertEq(isKing, true);
        assertEq(king, false);
    }
}
