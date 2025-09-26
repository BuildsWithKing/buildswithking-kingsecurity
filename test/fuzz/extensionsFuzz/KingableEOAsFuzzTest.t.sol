// SPDX-License-Identifier: MIT

/// @title KingableEOAsFuzzTest.
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on the 13th Of Sept, 2025.
 *
 *      KingableEOAs fuzz test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingableEOAsUnitTest, and KingableEOAs contract.
import {KingableEOAsUnitTest} from "../../unit/extensionsunit/KingableEOAsUnitTest.t.sol";
import {KingableEOAs} from "../../../src/extensions/KingableEOAs.sol";

contract KingableEOAsFuzzTest is KingableEOAsUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test: Only EOAs can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipOnlyEOA(address _randomKingAddress) external {
        // Assume: must be a valid address and not a contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _king
                && _randomKingAddress != address(kingableEOAs) && _randomKingAddress.code.length == 0
        );

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(_king, _randomKingAddress);
        kingableEOAs.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingableEOAs.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Invalid king reverts.
    /// @param _randomKingAddress The random king's address
    function testFuzz_InvalidKingReverts(address _randomKingAddress) external {
        // Assume random king address is not king's address.
        vm.assume(_randomKingAddress != _king);

        // If random king address is address zero, _king, kingable or contract address.
        if (
            _randomKingAddress == address(0) || _randomKingAddress == _king
                || _randomKingAddress == address(kingableEOAs) || _randomKingAddress.code.length > 0
        ) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, _randomKingAddress));
            vm.prank(_king);
            kingableEOAs.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized(_randomUserAddress, _king)
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _randomUserAddress, _king));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingableEOAs.renounceKingship();
    }

    /// @notice Fuzz test: King can renounce successfully.
    function testFuzz_RenounceKingshipByKing() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(_king, address(0));
        kingableEOAs.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableEOAs.currentKing(), address(0));
    }

    /// @notice Fuzz test: king can renounce kingship only once.
    function testFuzz_RenounceKingshipByKing_Reverts() external {
        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(_king, address(0));
        kingableEOAs.renounceKingship();

        // Revert Unauthorized(_king, _zeroAddress).
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _king, _zero));
        vm.prank(_king);
        kingableEOAs.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableEOAs.currentKing(), address(0));
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) external view {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Assign state.
        bool state = kingableEOAs.isKing(_randomUserAddress);

        // Assert state.
        assertEq(state, false);
        assertEq(kingableEOAs.isKing(_king), true);
    }
}
