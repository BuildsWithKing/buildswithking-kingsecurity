// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title  KingPausableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 23rd of Sept, 2025.
 *
 *     KingPausable unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, KingPausable, KingPausableMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingPausable} from "../../../src/extensions/KingPausable.sol";
import {KingPausableMockTest} from "../../mocks/KingPausableMockTest.t.sol";

contract KingPausableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ---------------------------------
    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() public view {
        // Assign _currentKing.
        address _currentKing = kingPausable.currentKing();

        // Assert both are equal.
        assertEq(KING, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingPausable.KingshipTransferred(ZERO, KING);
        kingPausable = new KingPausableMockTest(KING);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.InvalidKing.selector, ZERO));
        kingPausable = new KingPausableMockTest(ZERO);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingPausable.KingshipTransferred(ZERO, CONTRACTKING);
        kingPausable = new KingPausableMockTest(CONTRACTKING);
    }

    // -------------------------------------------------------- Test for king's write functions ---------------------------------
    /// @notice Test to ensure KING can pause and then activate contract.
    function testActivateContract_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(KING);
        kingPausable.pauseContract();

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractActivated(KING);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure KING can't activate contract once it's active.
    function testActivateContract_RevertsAlreadyActive() public {
        // Revert `AlreadyActive`.
        vm.expectRevert(KingPausable.AlreadyActive.selector);
        vm.prank(KING);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure only king can activate contract.
    function testActivateContract_RevertsUnauthorized() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure KING can pause contract.
    function testPauseContract_Succeeds() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(KING);
        kingPausable.pauseContract();
    }

    /// @notice Test to ensure KING can't pause contract once it's paused.
    function testPauseContract_RevertsAlreadyPaused() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(KING);
        kingPausable.pauseContract();

        // Revert `AlreadyPaused`.
        vm.expectRevert(KingPausable.AlreadyPaused.selector);
        vm.prank(KING);
        kingPausable.pauseContract();
    }

    /// @notice Test to ensure only king can pause contract.
    function testPauseContract_RevertsUnauthorized() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, USER2, KING));
        vm.prank(USER2);
        kingPausable.pauseContract();
    }

    // ----------------------------------------------------- Test for users public functions ---------------------------------------
    /// @notice Test to ensure users can check contract state.
    function testIsContractActive_Returns() public {
        // Prank as USER2.
        vm.prank(USER2);
        // Assign state.
        bool state = kingPausable.isContractActive();

        // Assert contract state is active (true).
        assertEq(state, true);
    }

    /// @notice Test to ensure users can't perform transactions once paused.
    function testIsContractActive_RevertsPausedContract() public {
        // Prank as KING
        vm.prank(KING);
        kingPausable.pauseContract();

        // Revert `PausedContract`.
        vm.expectRevert(KingPausable.PausedContract.selector);
        vm.prank(USER2);
        kingPausable.isContractActive();
    }

    /// @notice Test to ensure _currentKing returns king's address.
    function testCurrentKing_Returns() public view {
        // Assign _currentKing.
        address _currentKing = kingPausable.currentKing();

        // Assert both are equal.
        assertEq(_currentKing, KING);
    }

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing_Returns() public view {
        // Assign isKing.
        bool _isContractKing = kingPausable.isKing(KING);
        bool _king = kingPausable.isKing(CONTRACTKING);

        // Assert both are equal.
        assertEq(_isContractKing, true);
        assertEq(_king, false);
    }
}
