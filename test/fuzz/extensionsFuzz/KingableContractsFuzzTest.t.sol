// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableContractsFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 24th of Sept, 2025.
 *
 *      KingableContracts fuzz test contract, verifying all features works as intended.
 */

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
            _randomKingAddress != address(0) && _randomKingAddress != CONTRACTKING
                && _randomKingAddress != address(kingableContracts) && _randomKingAddress.code.length > 0
        );

        // Prank as CONTRACTKING.
        vm.prank(CONTRACTKING);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(CONTRACTKING, _randomKingAddress);
        kingableContracts.transferKingshipTo(_randomKingAddress);

        // Assert new king is set correctly.
        assertEq(kingableContracts.currentKing(), _randomKingAddress);
    }

    /// @notice Fuzz test invalid king reverts.
    /// @param _randomKingAddress The random king's address.
    function testFuzz_InvalidKingReverts(address _randomKingAddress) public {
        // Assume _randomAddress is not the contractking's address.
        vm.assume(_randomKingAddress != CONTRACTKING);

        // If random king address is address zero, CONTRACTKING, kingableContracts or EOAs.
        if (
            _randomKingAddress == address(0) || _randomKingAddress == address(kingableContracts)
                || _randomKingAddress.code.length == 0
        ) {
            // Revert InvalidKing.
            vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, _randomKingAddress));
            vm.prank(CONTRACTKING);
            kingableContracts.transferKingshipTo(_randomKingAddress);
        }
    }

    // ------------------------------------------------- Fuzz test: renounceKingship --------------------------------
    /// @notice Fuzz test RenounceKingship reverts Unauthorized.
    /// @param _randomUserAddress The random users address.
    function testFuzz_RenounceKingshipRevertsUnauthorized(address _randomUserAddress) public {
        // Assume random user address is not CONTRACTKING's address.
        vm.assume(_randomUserAddress != CONTRACTKING);

        // Revert Unauthorized(_randomUserAddress, CONTRACTKING).
        vm.expectRevert(
            abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _randomUserAddress, CONTRACTKING)
        );

        // Prank as random users.
        vm.prank(_randomUserAddress);
        kingableContracts.renounceKingship();
    }

    /// @notice Fuzz test: CONTRACTKING can renounce successfully.
    function testFuzz_RenounceKingshipByContractKing() public {
        // Prank as CONTRACTKING.
        vm.prank(CONTRACTKING);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(CONTRACTKING, address(0));
        kingableContracts.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableContracts.currentKing(), address(0));
    }

    /// @notice Fuzz test: CONTRACTKING can renounce kingship only once.
    function testFuzz_RenounceKingshipByContractKing_Reverts() public {
        // Prank as CONTRACTKING.
        vm.prank(CONTRACTKING);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(CONTRACTKING, address(0));
        kingableContracts.renounceKingship();

        // Revert Unauthorized(CONTRACTKING, ZEROAddress).
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, CONTRACTKING, ZERO));
        vm.prank(CONTRACTKING);
        kingableContracts.renounceKingship();

        // Assert no king afterwards.
        assertEq(kingableContracts.currentKing(), address(0));
    }

    // ------------------------------------------------ Fuzz test: isKing ----------------------------------
    /// @notice Fuzz testing isKing.
    /// @param _randomUserAddress The random users address.
    function testFuzz_IsKing(address _randomUserAddress) public view {
        // Assume random user address is not CONTRACTKING.
        vm.assume(_randomUserAddress != CONTRACTKING);

        // Assign state.
        bool state = kingableContracts.isKing(_randomUserAddress);

        // Assert state.
        assertEq(state, false);
        assertEq(kingableContracts.isKing(CONTRACTKING), true);
    }
}
