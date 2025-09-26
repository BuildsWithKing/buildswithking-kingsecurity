// SPDX-License-Identifier: MIT

/// @title KingableFuzzTest.
/// @author Michealking (@BuildsWithKing)
/**
 * @notice Created on the 25th Of Sept, 2025.
 *
 *      Kingable fuzz test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingableUnitTest, and Kingable contract.
import {KingableUnitTest} from "../../unit/coreunit/KingableUnitTest.t.sol";
import {Kingable} from "../../../src/core/Kingable.sol";

contract KingableFuzzTest is KingableUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test EOAs can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipEOA(address _randomKingAddress) external {
        // Assume: Random king's Address are EOAs.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _king && _randomKingAddress != address(kingable)
                && _randomKingAddress.code.length == 0
        );

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_king, _randomKingAddress);
        kingable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Contract addresses can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipContracts(address _randomKingAddress) external {
        // Assume: Random king's Address are contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _contractKing
                && _randomKingAddress != address(kingable) && _randomKingAddress.code.length > 0
        );

        // Prank as _king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(_king, _randomKingAddress);
        kingable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test invalid king reverts.
    /// @param _randomKingAddress The random king's address
    function testFuzz_InvalidKingReverts(address _randomKingAddress) external {
        // Assume random king address is not king's address.
        vm.assume(_randomKingAddress != _king);

        // If random king address is address zero, this contract or kingable.
        if (
            _randomKingAddress == address(0) || _randomKingAddress == address(this)
                || _randomKingAddress == address(kingable)
        ) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, _randomKingAddress));
            vm.prank(_king);
            kingable.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: King can renounce successfully.
    function testFuzz_RenounceKingshipByKing() external {
        // Prank as king.
        vm.prank(_king);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipRenounced(_king, address(0));
        kingable.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingable.currentKing(), address(0));
    }

    /// @notice Fuzz test RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Revert Unauthorized(_randomUserAddress, _king)
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, _randomUserAddress, _king));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingable.renounceKingship();
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) external {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != _king);

        // Prank as _random user.
        vm.prank(_randomUserAddress);
        bool state = kingable.isKing(_randomUserAddress);

        // Assert state is false.
        assertEq(state, false);
    }
}
