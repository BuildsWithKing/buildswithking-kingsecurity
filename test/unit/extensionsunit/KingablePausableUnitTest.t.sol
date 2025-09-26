// SPDX-License-Identifier: MIT

/// @title  KingablePausableUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *     KingablePausable unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, KingablePausable, KingablePausableMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingablePausable} from "../../../src/extensions/KingablePausable.sol";
import {KingablePausableMockTest} from "../../mocks/KingablePausableMockTest.t.sol";

contract KingablePausableUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ---------------------------------
    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingablePausable.currentKing();

        // Assert both are equal.
        assertEq(_king, _currentKing);
    }

    /// @notice Test to ensure constructor emits KingshipTransferred event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_zero, _king);
        kingablePausable = new KingablePausableMockTest(_king);
    }

    /// @notice Test to ensure address zero reverts.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.InvalidKing.selector, _zero));
        kingablePausable = new KingablePausableMockTest(_zero);
    }

    /// @notice Test to ensure contract addresses can be set as initial king.
    function testContractAddress_SucceedsIfSetAsInitialKing() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_zero, _contractKing);
        kingablePausable = new KingablePausableMockTest(_contractKing);
    }

    // -------------------------------------------------------- Test for king's write functions -----------------------------------
    /// @notice Test to ensure king can transfer kingship.
    function testTransferKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_king, _newKing);
        kingablePausable.transferKingshipTo(_newKing);

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _king, _newKing));
        vm.prank(_king);
        kingablePausable.transferKingshipTo(_newKing);
    }

    /// @notice Test to ensure king can transfer kingship to contract address.
    function testTransferKingship_SucceedsIfContractAddress() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_king, _contractKing);
        kingablePausable.transferKingshipTo(_contractKing);

        // Assert _contractKing is new _king.
        assertEq(kingablePausable.currentKing(), _contractKing);
    }

    /// @notice Test to ensure king can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() external {
        // Revert `SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.SameKing.selector, _king));
        vm.prank(_king);
        kingablePausable.transferKingshipTo(_king);

        // Assert current king is still _king.
        assertEq(kingablePausable.currentKing(), _king);
    }

    /// @notice Test to ensure king can't transfer kingship to address zero.
    function testTransferKingship_RevertsInvalidKing() external {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.InvalidKing.selector, _zero));
        vm.prank(_king);
        kingablePausable.transferKingshipTo(_zero);

        // Assert current king is still _king.
        assertEq(kingablePausable.currentKing(), _king);
    }

    /// @notice Test to ensure only king can transfer kingship.
    function testTransferKingship_RevertsIfNotKing() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingablePausable.transferKingshipTo(_newKing);

        // Assert current king is still _king.
        assertEq(kingablePausable.currentKing(), _king);
    }

    /// @notice Test to ensure king can renounce kingship.
    function testRenounceKingship_Succeeds() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipRenounced(_king, _zero);
        kingablePausable.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _king, _zero));
        vm.prank(_king);
        kingablePausable.renounceKingship();
    }

    /// @notice Test to ensure king can pause and then activate contract.
    function testActivateContract_Succeeds() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(_king);
        kingablePausable.pauseContract();

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractActivated(_king);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure king can't activate contract once it's active.
    function testActivateContract_RevertsAlreadyActive() external {
        // Revert `AlreadyActive`.
        vm.expectRevert(KingablePausable.AlreadyActive.selector);
        vm.prank(_king);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure only king can activate contract.
    function testActivateContract_RevertsUnauthorized() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingablePausable.activateContract();
    }

    /// @notice Test to ensure king can pause contract.
    function testPauseContract_Succeeds() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(_king);
        kingablePausable.pauseContract();
    }

    /// @notice Test to ensure king can't pause contract once it's paused.
    function testPauseContract_RevertsAlreadyPaused() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, false, false, false);
        emit KingablePausable.ContractPaused(_king);
        kingablePausable.pauseContract();

        // Revert `AlreadyPaused`.
        vm.expectRevert(KingablePausable.AlreadyPaused.selector);
        vm.prank(_king);
        kingablePausable.pauseContract();
    }

    /// @notice Test to ensure only king can pause contract.
    function testPauseContract_RevertsUnauthorized() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _user2, _king));
        vm.prank(_user2);
        kingablePausable.pauseContract();
    }

    // ----------------------------------------------------- Test for users public functions ---------------------------------------
    /// @notice Test to ensure users can check contract state.
    function testIsContractActive_Returns() external {
        // Prank as _user2.
        vm.prank(_user2);
        // Assign state.
        bool state = kingablePausable.isContractActive();

        // Assert contract state is active (true).
        assertEq(state, true);
    }

    /// @notice Test to ensure users can't perform transactions once paused.
    function testIsContractActive_RevertsPausedContract() external {
        // Prank as _king
        vm.prank(_king);
        kingablePausable.pauseContract();

        // Revert `PausedContract`.
        vm.expectRevert(KingablePausable.PausedContract.selector);
        vm.prank(_user2);
        kingablePausable.isContractActive();
    }

    /// @notice Test to ensure currentKing returns king's address.
    function testCurrentKing_Returns() external view {
        // Assign currentKing.
        address currentKing = kingablePausable.currentKing();

        // Assert both are equal.
        assertEq(currentKing, _king);
    }

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing_Returns() external view {
        // Assign isKing.
        bool isKing = kingablePausable.isKing(_king);
        bool king = kingablePausable.isKing(_contractKing);

        // Assert both are equal.
        assertEq(isKing, true);
        assertEq(king, false);
    }
}
