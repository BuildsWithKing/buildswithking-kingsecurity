// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 25th of Sept, 2025.
 *
 *      Kingable fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingableUnitTest, and Kingable contract.
import {KingableUnitTest} from "../../unit/coreunit/KingableUnitTest.t.sol";
import {Kingable} from "../../../src/core/Kingable.sol";

contract KingableFuzzTest is KingableUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test EOAs can become KING.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipEOA(address _randomKingAddress) public {
        // Assume: Random king's Address are EOAs.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != KING && _randomKingAddress != address(kingable)
                && _randomKingAddress.code.length == 0
        );

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(KING, _randomKingAddress);
        kingable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test: Contract addresses can become KING.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipContracts(address _randomKingAddress) public {
        // Assume: Random king's Address are contract.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != CONTRACTKING
                && _randomKingAddress != address(kingable) && _randomKingAddress.code.length > 0
        );

        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipTransferred(KING, _randomKingAddress);
        kingable.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingable.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test invalid king reverts.
    /// @param _randomKingAddress The random king's address
    function testFuzz_InvalidKingReverts(address _randomKingAddress) public {
        // Assume random king address is not king's address.
        vm.assume(_randomKingAddress != KING);

        // If random king address is address zero or kingable.
        if (_randomKingAddress == address(0) || _randomKingAddress == address(kingable)) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(Kingable.InvalidKing.selector, _randomKingAddress));
            vm.prank(KING);
            kingable.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test: KING can renounce successfully.
    function testFuzz_RenounceKingshipByKing() public {
        // Prank as KING.
        vm.prank(KING);
        vm.expectEmit(true, true, false, false);
        emit Kingable.KingshipRenounced(KING, address(0));
        kingable.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingable.currentKing(), address(0));
    }

    /// @notice Fuzz test RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Revert Unauthorized(_randomUserAddress, KING)
        vm.expectRevert(abi.encodeWithSelector(Kingable.Unauthorized.selector, _randomUserAddress, KING));

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingable.renounceKingship();
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) public {
        // Assume random user address is not king's address.
        vm.assume(_randomUserAddress != KING);

        // Prank as _random user.
        vm.prank(_randomUserAddress);
        bool state = kingable.isKing(_randomUserAddress);

        // Assert state is false.
        assertEq(state, false);
    }
}
