// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20FuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 07th of Nov, 2025.
 *
 *  @dev   KingERC20 fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingERC20UnitTest, KingERC20, KingERC20Errors, KingERC20MockTest contract and IERC20 interface.
import {KingERC20UnitTest} from "./KingERC20UnitTest.t.sol";
import {KingERC20} from "../../../../src/tokens/ERC20/KingERC20.sol";
import {KingERC20Errors} from "../../../../src/tokens/errors/KingERC20Errors.sol";
import {KingERC20MockTest} from "../../../mocks/KingERC20MockTest.t.sol";
import {IERC20} from "../../../../src/tokens/ERC20/interfaces/IERC20.sol";

contract KingERC20FuzzTest is KingERC20UnitTest {
    // ------------------------------------------------ Private Helper Function ------------------------------
    /// @notice Private helper function that validates a fuzzed address.
    /// @param randomAddress_ The random address.
    function _assume(address randomAddress_) private {
        // Assume: The random address is not the zero, the king, the dead or the contract address.
        vm.assume(
            randomAddress_ != address(0) && randomAddress_ != KING && randomAddress_ != address(0xdead)
                && randomAddress_ != address(kingERC20)
        );
    }

    // ------------------------------------------------ Fuzz Test: Transfer ----------------------------------
    /// @notice Fuzz test transfer token succeeds.
    /// @param to The receiver's address.
    /// @param amount The amount of token's to be sent.
    function testFuzz_Transfer_Succeeds(address to, uint256 amount) public {
        // Call the private `_assume` helper function.
        _assume(to);

        // Bound token amount to the valid range (1,000 to 1,000,000).
        amount = bound(amount, ONE_THOUSAND, ONE_MILLION);

        // Assume amount is less than the king's balance.
        vm.assume(amount <= kingERC20.balanceOf(KING));

        // Emit the event Transfer and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Transfer(KING, to, amount);
        vm.prank(KING);
        kingERC20.transfer(to, amount);

        // Assert the address received the exact token amount.
        assertEq(kingERC20.balanceOf(to), amount);
    }

    /// @notice Fuzz test transfer token reverts Insufficient balance.
    /// @param from The sender's address.
    /// @param to The receiver's address.
    /// @param amount The amount of token's to be sent.
    function testFuzz_Transfer_RevertsInsufficientBalance(address from, address to, uint256 amount) public {
        // Call the private `_assume` helper function.
        _assume(from);

        // Call the private `_assume` helper function.
        _assume(to);

        // Bound token amount to the valid range (1,000 to 1,000,000).
        amount = bound(amount, ONE_THOUSAND, ONE_MILLION);

        // Assume amount is less than the king's balance.
        vm.assume(amount <= kingERC20.balanceOf(KING));

        // Revert since the sender's balance is zero.
        vm.expectRevert(abi.encodeWithSelector(KingERC20Errors.InsufficientBalance.selector, kingERC20.balanceOf(from)));
        vm.prank(from);
        kingERC20.transfer(to, amount);
    }

    // --------------------------------------------------- Fuzz Test: Approve ----------------------------------
    /// @notice Fuzz test approve token succeeds.
    /// @param  spender The spender's address.
    /// @param  amount The amount of token to be spent by the spender.
    function testFuzz_Approve_Succeeds(address spender, uint256 amount) public {
        // Call the private `_assume` helper function.
        _assume(spender);

        // Bound token amount to the valid range (1,000 to 1,000,000).
        amount = bound(amount, ONE_THOUSAND, ONE_MILLION);

        // Assume amount is less than the king's balance.
        vm.assume(amount <= kingERC20.balanceOf(KING));

        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, spender, amount);
        vm.prank(KING);
        kingERC20.approve(spender, amount);

        // Assert the address's allowance is equal to the amount.
        assertEq(kingERC20.allowance(KING, spender), amount);
    }

    // ----------------------------------------------------- Fuzz Test: Transfer From ---------------------------
    /// @notice Fuzz test transfer from succeeds.
    /// @param from The user's address.
    /// @param to The spender's address.
    /// @param amount The amount of token to be spent by the spender.
    function testFuzz_TransferFrom_Succeeds(address from, address to, uint256 amount) public {
        // Call the private `_assume` helper function.
        _assume(from);

        // Call the private `_assume` helper function.
        _assume(to);

        // Bound token amount to the valid range (1,000 to 1,000,000).
        amount = bound(amount, ONE_THOUSAND, ONE_MILLION);

        // Assume amount is less than the king's balance.
        vm.assume(amount <= kingERC20.balanceOf(KING));

        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, to, amount);
        vm.prank(KING);
        kingERC20.approve(to, amount);

        // Emit the event Transfer and prank as the spender.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Transfer(KING, to, amount);
        vm.prank(to);
        kingERC20.transferFrom(KING, to, amount);

        // Assert the address's allowance is equal to the amount.
        assertEq(kingERC20.allowance(KING, to), 0);
    }
}
