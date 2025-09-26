// SPDX-License-Identifier: MIT

/// @title KingableContractsFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 24th Of Sept, 2025.
 *
 *      KingableContracts fuzz test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports KingableContractsUnitTest, and KingableContracts contract.
import {KingableContractsUnitTest} from "../../unit/extensionsunit/KingableContractsUnitTest.t.sol";
import {KingableContracts} from "../../../src/extensions/KingableContracts.sol";

contract KingableContractsFuzzTest is KingableContractsUnitTest {
    // ------------------------------------------------- Fuzz test: transferKingship --------------------------------
    /// @notice Fuzz test: Only Contract addresses can become king.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_TransferKingshipOnlyContracts(address _randomKingAddress) external {
        // Assume: Must be a valid contract address not EOAs.
        vm.assume(
            _randomKingAddress != address(0) && _randomKingAddress != _contractKing
                && _randomKingAddress != address(kingableContracts) && _randomKingAddress.code.length > 0
        );

        // Prank as _contractKing.
        vm.prank(_contractKing);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(_contractKing, _randomKingAddress);
        kingableContracts.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingableContracts.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test invalid king reverts.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_InvalidKingReverts(address _randomKingAddress) external {
        // If random king address is address zero, _contractKing, kingableContracts or EOAs.
        if (
            _randomKingAddress == address(0) || _randomKingAddress == _contractKing
                || _randomKingAddress == address(kingableContracts) || _randomKingAddress.code.length == 0
        ) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, _randomKingAddress));
            vm.prank(_contractKing);
            kingableContracts.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) external {
        // Assume random user address is not contract king's address.
        vm.assume(_randomUserAddress != _contractKing);

        // Revert Unauthorized(_randomUserAddress, _contractKing).
        vm.expectRevert(
            abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _randomUserAddress, _contractKing)
        );

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingableContracts.renounceKingship();
    }

    /// @notice Fuzz test: contractKing can renounce successfully.
    function testFuzz_RenounceKingshipByContractKing() external {
        // Prank as _contractKing.
        vm.prank(_contractKing);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(_contractKing, address(0));
        kingableContracts.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableContracts.currentKing(), address(0));
    }

    /// @notice Fuzz test: contractKing can renounce kingship only once.
    function testFuzz_RenounceKingshipByContractKing_Reverts() external {
        // Prank as _contractKing.
        vm.prank(_contractKing);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(_contractKing, address(0));
        kingableContracts.renounceKingship();

        // Revert Unauthorized(_contractKing, _zeroAddress).
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _contractKing, _zero));
        vm.prank(_contractKing);
        kingableContracts.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableContracts.currentKing(), address(0));
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) external view {
        // Assume random user address is not contract king.
        vm.assume(_randomUserAddress != _contractKing);

        // Assign state.
        bool state = kingableContracts.isKing(_randomUserAddress);

        // Assert state.
        assertEq(state, false);
        assertEq(kingableContracts.isKing(_contractKing), true);
    }
}
