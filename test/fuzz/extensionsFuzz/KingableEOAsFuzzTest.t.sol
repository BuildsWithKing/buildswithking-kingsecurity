// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableEOAsFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 13th of Sept, 2025.
 *
 *      KingableEOAs fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingableEOAsUnitTest, and KingableEOAs contract.
import {KingableEOAsUnitTest} from "../../unit/extensionsunit/KingableEOAsUnitTest.t.sol";
import {KingableEOAs} from "../../../src/extensions/KingableEOAs.sol";

contract KingableEOAsFuzzTest is KingableEOAsUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test: Only EOAs can become KING.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipOnlyEOA(address _randomKingAddress) public {
        // Assume: must be a valid address and not a contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != KING
                && _randomKingAddress != address(kingableEOAs) && _randomKingAddress.code.length == 0
        );

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipTransferred(KING, _randomKingAddress);
        kingableEOAs.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingableEOAs.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Invalid king reverts.
    /// @param _randomKingAddress The random king's address
    function testFuzz_InvalidKingReverts(address _randomKingAddress) public {
        // Assume random king address is not king's address.
        vm.assume(_randomKingAddress != KING);

        // If random king address is address zero, KING, kingable or contract address.
        if (
            _randomKingAddress == address(0) || _randomKingAddress == KING
                || _randomKingAddress == address(kingableEOAs) || _randomKingAddress.code.length > 0
        ) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(KingableEOAs.InvalidKing.selector, _randomKingAddress));
            vm.prank(KING);
            kingableEOAs.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Revert Unauthorized(_randomUserAddress, KING)
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, _randomUserAddress, KING));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingableEOAs.renounceKingship();
    }

    /// @notice Fuzz test: KING can renounce successfully.
    function testFuzz_RenounceKingshipByKing() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(KING, address(0));
        kingableEOAs.renounceKingship();

        // Assert no KING afterwards.
        assertEq(kingableEOAs.currentKing(), address(0));
    }

    /// @notice Fuzz test: KING can renounce kingship only once.
    function testFuzz_RenounceKingshipByKing_Reverts() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit KingableEOAs.KingshipRenounced(KING, address(0));
        kingableEOAs.renounceKingship();

        // Revert Unauthorized(KING, ZEROAddress).
        vm.expectRevert(abi.encodeWithSelector(KingableEOAs.Unauthorized.selector, KING, ZERO));
        vm.prank(KING);
        kingableEOAs.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableEOAs.currentKing(), address(0));
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) public view {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Assign state.
        bool state = kingableEOAs.isKing(_randomUserAddress);

        // Assert state.
        assertEq(state, false);
        assertEq(kingableEOAs.isKing(KING), true);
    }
}
