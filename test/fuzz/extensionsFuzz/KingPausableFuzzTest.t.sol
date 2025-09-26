// SPDX-License-Identifier: MIT

/// @title KingPausableFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 25th Of Sept, 2025.
 *
 *      KingPausable fuzz test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingPausableUnitTest, and KingPausable contract.
import {KingPausableUnitTest} from "../../unit/extensionsunit/KingPausableUnitTest.t.sol";
import {KingPausable} from "../../../src/extensions/KingPausable.sol";

contract KingPausableFuzzTest is KingPausableUnitTest {
     // ----------------------------------------------- Fuzz Test: activate contract ---------------------------------------------

    /// @notice Fuzz test: Activate contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_ActivateContractRevertsUnauthorized(address _randomUserAddress) external {
        // Prank as _king.
        vm.prank(_king);
        kingPausable.pauseContract();

        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, _randomUserAddress, _king));
        vm.prank(_randomUserAddress);
        kingPausable.activateContract();

        // Revert PausedContract.
        vm.expectRevert(KingPausable.PausedContract.selector);
        kingPausable.isContractActive();
    }

    // ------------------------------------------------ Fuzz test: Pause contract ----------------------------------------------
    /// @notice Fuzz test: Paused contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_PauseContractRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingPausable.Unauthorized.selector, _randomUserAddress, _king));
        vm.prank(_randomUserAddress);
        kingPausable.pauseContract();

        // Assign state.
        bool state = kingPausable.isContractActive();

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
        bool state = kingPausable.isKing(_randomUserAddress);

        // Assert state is false.
        assertEq(state, false);
    }
}