// SPDX-License-Identifier: MIT

/// @title  KingPausableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 23rd Of Sept, 2025.
 *
 *     KingPausable unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, KingPausable, KingPausableMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingPausable} from "../../../src/extensions/KingPausable.sol";
import {KingPausableMockTest} from "../../mocks/KingPausableMockTest.t.sol";

contract KingPausableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ---------------------------------
    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingPausable.currentKing();

        // Assert both are equal.
        assertEq(_king, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingPausable.KingshipTransferred(_zero, _king);
        kingPausable = new KingPausableMockTest(_king);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.InvalidKing.selector, _zero));
        kingPausable = new KingPausableMockTest(_zero);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingPausable.KingshipTransferred(_zero, _contractKing);
        kingPausable = new KingPausableMockTest(_contractKing);
    }

    // -------------------------------------------------------- Test for king's write functions ---------------------------------
    /// @notice Test to ensure king can pause and then activate contract.
    function testActivateContract_Succeeds() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(_king);
        kingPausable.pauseContract();

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractActivated(_king);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure king can't activate contract once it's active.
    function testActivateContract_RevertsAlreadyActive() external {
        // Revert `AlreadyActive`.
        vm.expectRevert(KingPausable.AlreadyActive.selector);
        vm.prank(_king);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure only king can activate contract.
    function testActivateContract_RevertsUnauthorized() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingPausable.activateContract();
    }

    /// @notice Test to ensure king can pause contract.
    function testPauseContract_Succeeds() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(_king);
        kingPausable.pauseContract();
    }

    /// @notice Test to ensure king can't pause contract once it's paused.
    function testPauseContract_RevertsAlreadyPaused() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingPausable.ContractPaused(_king);
        kingPausable.pauseContract();

        // Revert `AlreadyPaused`.
        vm.expectRevert(KingPausable.AlreadyPaused.selector);
        vm.prank(_king);
        kingPausable.pauseContract();
    }

    /// @notice Test to ensure only king can pause contract.
    function testPauseContract_RevertsUnauthorized() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingPausable.pauseContract();
    }

    // ----------------------------------------------------- Test for users public functions ---------------------------------------
    /// @notice Test to ensure users can check contract state.
    function testIsContractActive_Returns() external {
        // Prank as _user2.
        vm.prank(_user2);
        // Assign state.
        bool state = kingPausable.isContractActive();

        // Assert contract state is active (true).
        assertEq(state, true);
    }

    /// @notice Test to ensure users can't perform transactions once paused.
    function testIsContractActive_RevertsPausedContract() external {
        // Prank as _king
        vm.prank(_king);
        kingPausable.pauseContract();

        // Revert `PausedContract`.
        vm.expectRevert(KingPausable.PausedContract.selector);
        vm.prank(_user2);
        kingPausable.isContractActive();
    }

    /// @notice Test to ensure currentKing returns king's address.
    function testCurrentKing_Returns() external view {
        // Assign currentKing.
        address currentKing = kingPausable.currentKing();

        // Assert both are equal.
        assertEq(currentKing, _king);
    }

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing_Returns() external view {
        // Assign isKing.
        bool isContractKing = kingPausable.isKing(_king);
        bool king = kingPausable.isKing(_contractKing);

        // Assert both are equal.
        assertEq(isContractKing, true);
        assertEq(king, false);
    }
}
