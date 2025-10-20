// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingablePausableFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 25th of Sept, 2025.
 *
 *      KingablePausable fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingablePausableUnitTest, and KingablePausable contract.
import {KingablePausableUnitTest} from "../../unit/extensionsunit/KingablePausableUnitTest.t.sol";
import {KingablePausable} from "../../../src/extensions/KingablePausable.sol";

contract KingablePausableFuzzTest is KingablePausableUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test EOAs can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipEOA(address _randomKingAddress) public {
        // Assume: Random king's Address are EOAs.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != KING
                && _randomKingAddress != address(kingablePausable) && _randomKingAddress.code.length == 0
        );

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(KING, _randomKingAddress);
        kingablePausable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingablePausable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Contract addresses can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipContracts(address _randomKingAddress) public {
        // Assume: Random king's Address are contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != CONTRACTKING
                && _randomKingAddress != address(kingablePausable) && _randomKingAddress.code.length > 0
        );

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipTransferred(KING, _randomKingAddress);
        kingablePausable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingablePausable.currentKing(), _randomKingAddress);
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: King can renounce successfully.
    function testFuzz_RenounceKingshipByKing() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingablePausable.KingshipRenounced(KING, address(0));
        kingablePausable.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingablePausable.currentKing(), address(0));
    }

    /// @notice Fuzz test: RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Revert Unauthorized(_randomUserAddress, KING)
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, KING));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingablePausable.renounceKingship();
    }

    // ----------------------------------------------- Fuzz Test: activate contract ---------------------------------------------

    /// @notice Fuzz test: Activate contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_ActivateContractRevertsUnauthorized(address _randomUserAddress) public {
        // Prank as KING.
        vm.prank(KING);
        kingablePausable.pauseContract();

        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, KING));
        vm.prank(_randomUserAddress);
        kingablePausable.activateContract();

        // Revert PausedContract.
        vm.expectRevert(KingablePausable.PausedContract.selector);
        kingablePausable.isContractActive();
    }

    // ------------------------------------------------ Fuzz test: Pause contract ----------------------------------------------
    /// @notice Fuzz test: Paused contract reverts.
    /// @param _randomUserAddress The random user's address.
    function testFuzz_PauseContractRevertsUnauthorized(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingablePausable.Unauthorized.selector, _randomUserAddress, KING));
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
    function testFuzz_IsKing(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Prank as _random user.
        vm.prank(_randomUserAddress);
        bool state = kingablePausable.isKing(_randomUserAddress);

        // Assert state is false.
        assertEq(state, false);
    }
}
