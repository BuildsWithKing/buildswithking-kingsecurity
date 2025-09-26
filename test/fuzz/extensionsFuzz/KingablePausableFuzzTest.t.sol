// SPDX-License-Identifier: MIT

/// @title KingablePausableFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 25th Of Sept, 2025.
 *
 *      KingablePausable fuzz test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingablePausableUnitTest, and KingablePausable contract.
import {KingablePausableUnitTest} from "../../unit/extensionsunit/KingablePausableUnitTest.t.sol";
import {KingablePausable} from "../../../src/extensions/KingablePausable.sol";

contract KingablePausableFuzzTest is KingablePausableUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test EOAs can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipEOA(address _randomKingAddress) external {
        // Assume: Random king's Address are EOAs.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _king
                && _randomKingAddress != address(kingablePausable) && _randomKingAddress.code.length == 0
        );

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_king, _randomKingAddress);
        kingablePausable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingablePausable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Contract addresses can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipContracts(address _randomKingAddress) external {
        // Assume: Random king's Address are contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _contractKing
                && _randomKingAddress != address(kingablePausable) && _randomKingAddress.code.length > 0
        );

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(_king, _randomKingAddress);
        kingablePausable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingablePausable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test invalid king reverts.
    /// @param _randomKingAddress The random king's address
    function testFuzz_InvalidKingReverts(address _randomKingAddress) external {
        // Assume random king address is not king's address.
        vm.assume(_randomKingAddress != _king);

        // If random king address is address zero, this contract or kingablePausable.
        if (_randomKingAddress == address(this) || _randomKingAddress == address(0)) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(KingablePausable.InvalidKing.selector, _randomKingAddress));
            vm.prank(_king);
            kingablePausable.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: King can renounce successfully.
    function testFuzz_RenounceKingshipByKing() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipRenounced(_king, address(0));
        kingablePausable.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingablePausable.currentKing(), address(0));
    }

    /// @notice Fuzz test: RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized(_randomUserAddress, _king)
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, _king));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingablePausable.renounceKingship();
    }

    // ----------------------------------------------- Fuzz Test: activate contract ---------------------------------------------

    /// @notice Fuzz test: Activate contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_ActivateContractRevertsUnauthorized(address _randomUserAddress) external {
        // Prank as _king.
        vm.prank(_king);
        kingablePausable.pauseContract();

        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, _king));
        vm.prank(_randomUserAddress);
        kingablePausable.activateContract();

        // Revert PausedContract.
        vm.expectRevert(KingablePausable.PausedContract.selector);
        kingablePausable.isContractActive();
    }

    // ------------------------------------------------ Fuzz test: Pause contract ----------------------------------------------
    /// @notice Fuzz test: Paused contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_PauseContractRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, _king));
        vm.prank(_randomUserAddress);
        kingablePausable.pauseContract();

        // Assign state.
        bool state = kingablePausable.isContractActive();

        // Assert contract is still active (pause attempt failed).
        assertEq(state, true);
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz test: isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Prank as _random user.
        vm.prank(_randomUserAddress);
        bool state = kingablePausable.isKing(_randomUserAddress);

        // Assert state is false.
        assertEq(state, false);
    }
}
