// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingClaimMistakenETHUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 8th of Oct, 2025.
 *
 * @dev    Unit test contract ensuring KingClaimMistakenETH contract works as intended.
 */

/// @notice Imports BaseTest, KingClaimMistakenETH and KingReentrancyAttacker contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingClaimMistakenETH} from "../../../src/guards/KingClaimMistakenETH.sol";
import {KingReentrancyAttacker} from "../../../src/utils/KingReentrancyAttacker.sol";

contract KingClaimMistakenETHUnitTest is BaseTest {
    // -------------------------------------- Private Helper Function -------------------------------
    /// @notice This helper function pranks and deposit ETH as user2.
    function _prankAndDepositAsUser2() private {
        /*  Emit the event `MistakenETHDeposited`
            prank and deposit as USER2. 
        */
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHDeposited(USER2, ETH_AMOUNT);
        vm.prank(USER2);
        // Simulate accidental ETH deposit to the contract (no calldata).
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: ETH_AMOUNT}("");
        assertTrue(success);
    }

    // -------------------------------------- Unit Test: Users Write Function -----------------------
    /// @notice Test to ensure users can claim ETH mistakenly sent.
    function testClaimMistakenETH_Succeeds() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        /*  Emit the event `MistakenETHClaimed` 
            prank & claimMistakenETH as USER2. 
        */
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHClaimed(USER2, USER2, ETH_AMOUNT);
        vm.prank(USER2);
        kingClaimMistakenETH.claimMistakenETH();

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert totalMistakenETH balance after withdrawal is less than the balance before.
        assertLt(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure users can claim ETH to an alternate Address.
    function testClaimMistakenETHTo_Succeeds() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Assign _alternateAddress.
        address _alternateAddress = address(30);

        /* Emit the event `MistakenETHClaimed` 
           prank & claimMistakenETHTo an alternate address as USER2. 
        */
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHClaimed(USER2, _alternateAddress, ETH_AMOUNT);
        vm.prank(USER2);
        kingClaimMistakenETH.claimMistakenETHTo(_alternateAddress);

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert totalMistakenETH balance after withdrawal is less than the balance before.
        assertLt(balanceAfter, balanceBefore);

        // Assert _alternateAddress's balance is equal to 1 ETH.
        assertEq(_alternateAddress.balance, ETH_AMOUNT);
    }

    /// @notice Test to ensure users cannot claim ETH to the zero address.
    function testClaimMistakenETHTo_RevertsInvalidAddress() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Revert `InvalidAddress`, Since alternateAddress is the zero address.
        vm.expectRevert(abi.encodeWithSelector(KingClaimMistakenETH.InvalidAddress.selector, ZERO));
        vm.prank(USER2);
        kingClaimMistakenETH.claimMistakenETHTo(ZERO);

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert totalMistakenETH balance after is equal to the balance before.
        assertEq(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure users with zero balance cannot claim ETH.
    function testClaimMistakenETH_RevertsInsufficientFunds() public {
        // Revert `InsufficientFunds` and prank as USER1.
        vm.expectRevert(KingClaimMistakenETH.InsufficientFunds.selector);
        vm.prank(USER1);
        kingClaimMistakenETH.claimMistakenETH();
    }

    /// @notice Test to ensure `ClaimFailed` reverts for failed ETH claim.
    function testClaimMistakenETH_RevertsClaimFailed() public {
        // Fund kingRejectETH 10 ETH.
        vm.deal(address(kingRejectETH), STARTING_BALANCE);

        // Prank and deposit as kingRejectETH.
        vm.prank(address(kingRejectETH));
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Revert `ClaimFailed` and prank as kingRejectETH.
        vm.expectRevert(KingClaimMistakenETH.ClaimFailed.selector);
        vm.prank(address(kingRejectETH));
        kingClaimMistakenETH.claimMistakenETH();

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert totalMistakenETH balance after is equal to the balance before.
        assertEq(balanceAfter, balanceBefore);
    }

    /// @notice Test to ensure the non-reentrant modifier prevents any attack attempts.
    function testClaimMistakenETH_NonReentrant_Reverts() public {
        // Create a new instance of KingReentrancyAttacker.
        kingReentrancyAttacker = new KingReentrancyAttacker(payable(address(kingClaimMistakenETH)), MAX_REENTRANCY);

        // Deposit ETH to the targetted contract as attacker.
        vm.prank(attacker);
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Revert `ClaimFailed`, due to the non-reentrant modifier.
        vm.expectRevert(KingClaimMistakenETH.ClaimFailed.selector);
        vm.prank(attacker);
        kingReentrancyAttacker.fundAndAttack{value: ETH_AMOUNT}();
    }

    // --------------------------------------- Unit Test: Users Read Function ------------------------
    /// @notice Test to ensure users can successfully view their balance.
    function testMyMistakenETHBalance_Returns() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Prank as User2 and assign user2's balance.
        vm.prank(USER2);
        uint256 myBalance = kingClaimMistakenETH.myMistakenETHBalance();

        // Assert user2's balance is equal to 1 ETH.
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test to ensure users can successfully view other users mistaken ETH balance.
    function testUserMistakenETHBalance_Returns() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Prank as USER1.
        vm.prank(USER1);
        uint256 userBalance = kingClaimMistakenETH.userMistakenETHBalance(USER2);

        // Assert USER2's mistakenETHBalance is equal to 1 ETH.
        assertEq(userBalance, ETH_AMOUNT);
    }

    /// @notice Test to ensure users can view total mistaken ETH (Contract balance).
    function testTotalMistakenETH_Returns() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Prank as USER1.
        vm.prank(USER1);
        uint256 totalMistakenETH = kingClaimMistakenETH.totalMistakenETH();

        // Assert totalMistakenETH is equal to 1 ETH.
        assertEq(totalMistakenETH, ETH_AMOUNT);
    }

    /// @notice Test to ensure users can view total recorded mistaken ETH.
    function testTotalRecordedMistakenETH_Returns() public {
        // Call the private `_prankAndDepositAsUser2` helper function.
        _prankAndDepositAsUser2();

        // Prank and claimMistakenETH as USER2.
        vm.prank(USER2);
        kingClaimMistakenETH.claimMistakenETH();

        // Prank as USER1.
        vm.prank(USER1);
        uint256 totalRecordedMistakenETH = kingClaimMistakenETH.totalRecordedMistakenETH();

        // Assert totalRecordedMistakenETH is equal to 1 ETH.
        assertEq(totalRecordedMistakenETH, ETH_AMOUNT);
    }
    // --------------------------------------- Unit Test: Receive & FallBack -------------------------

    /// @notice Test to ensure users cannot deposit zero ETH with no calldata.
    function testReceive_RevertsAmountTooLow() public {
        // Revert `AmountTooLow`.
        vm.expectRevert(KingClaimMistakenETH.AmountTooLow.selector);
        // Prank as USER1.
        vm.prank(USER1);
        payable(address(kingClaimMistakenETH)).call{value: 0}("");

        // Assert contract balance is equal to zero.
        assertEq(address(kingClaimMistakenETH).balance, 0);
    }

    /// @notice Test to ensure users cannot deposit zero ETH with calldata.
    function testFallback_RevertsAmountTooLow() public {
        // Revert `AmountTooLow`.
        vm.expectRevert(KingClaimMistakenETH.AmountTooLow.selector);
        // Prank as USER1.
        vm.prank(USER1);
        payable(address(kingClaimMistakenETH)).call{value: 0}(
            hex"55241077000000000000000000000000000000000000000000000000000000000000007b"
        );

        // Assert contract balance is equal to zero.
        assertEq(address(kingClaimMistakenETH).balance, 0);
    }

    /// @notice Test to ensure users can deposit ETH with call data.
    function testFallback_Succeeds() public {
        // Assign balanceBefore.
        uint256 balanceBefore = address(kingClaimMistakenETH).balance;

        /*  Emit the event `MistakenETHDeposited`
            prank and deposit as USER2. 
        */
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHDeposited(USER2, ETH_AMOUNT);
        vm.prank(USER2);
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: ETH_AMOUNT}(
            hex"55241077000000000000000000000000000000000000000000000000000000000000007b"
        );
        assertTrue(success);

        // Assign balanceAfter.
        uint256 balanceAfter = address(kingClaimMistakenETH).balance;

        // Assert balance after is greater than the balance before.
        assertGt(balanceAfter, balanceBefore);
    }
}
