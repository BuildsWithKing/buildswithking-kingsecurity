// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingClaimMistakenETHFuzzTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 9th of Oct, 2025.
 *
 *      KingClaimMistakenETH fuzz test contract, verifying all features works as intended.
 */

/// @notice Imports KingClaimMistakenETHUnitTest, and KingClaimMistakenETH contract.
import {KingClaimMistakenETHUnitTest} from "../../unit/guardsunit/KingClaimMistakenETHUnitTest.t.sol";
import {KingClaimMistakenETH} from "../../../src/guards/KingClaimMistakenETH.sol";

contract KingClaimMistakenETHFuzzTest is KingClaimMistakenETHUnitTest {
    // ------------------------------------------- Private Helper Function --------------------------------------
    /// @notice Private helper function that validates a fuzzed user address.
    function _assume(address _userAddress) private view {
        // Assume _userAddress passes all conditions below.
        vm.assume(
            _userAddress != address(0) && _userAddress != address(kingClaimMistakenETH) && _userAddress != KING
                && _userAddress != address(0xdead) && _userAddress != USER2 && _userAddress.code.length == 0
                && _userAddress != address(kingRejectETH)
        );
    }

    // ------------------------------------------- Fuzz test: Users Write Function ------------------------------------
    /// @notice Fuzz test to ensure multiple users can mistakenly fund contract and claim back their ETH.
    /// @param _userAddress The user's address.
    /// @param _ethAmount The amount of ETH funded or claimed.
    function testFuzz_ClaimMistakenETH_Succeeds(address _userAddress, uint256 _ethAmount) public {
        // Call private _assume helper function.
        _assume(_userAddress);

        // Assign _oneQuadrillionWei.
        uint256 _oneQuadrillionWei = 1e15;

        // Bound _ethAmount to valid ETH range (0.001 ETH to 10 ETH).
        _ethAmount = bound(_ethAmount, _oneQuadrillionWei, STARTING_BALANCE);

        // Fund _userAddress.
        vm.deal(_userAddress, _ethAmount);

        // Prank and deposit as _userAddress.
        vm.prank(_userAddress);
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHDeposited(_userAddress, _ethAmount);
        payable(address(kingClaimMistakenETH)).call{value: _ethAmount}("");

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Claim as _userAddress.
        vm.prank(_userAddress);
        kingClaimMistakenETH.claimMistakenETH();

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert _userAddress balance is equal to zero.
        assertEq(kingClaimMistakenETH.userMistakenETHBalance(_userAddress), 0);

        // Assert totalMistakenETH balance before is greater than balance after.
        assertGt(balanceBefore, balanceAfter);

        // Assert _userAddress balance is equal to _ethAmount.
        assertEq(_userAddress.balance, _ethAmount);
    }

    /// @notice Fuzz test to ensure multiple users can mistakenly fund contract and claim back ETH to an alternate address.
    /// @param _userAddress The user's address.
    /// @param _alternateAddress The alternate address.
    /// @param _ethAmount The amount of ETH funded or claimed.
    function testFuzz_ClaimMistakenETHTo_Succeeds(address _userAddress, address _alternateAddress, uint256 _ethAmount)
        public
    {
        // Assume _userAddress is not equal to _alternateAddress.
        vm.assume(_userAddress != _alternateAddress);

        // Call private _assume helper function.
        _assume(_userAddress);

        // Call private _assume helper function.
        _assume(_alternateAddress);

        // Revert `InvalidAddress`, if _alternateAddress is a contract address.
        if (_alternateAddress.code.length > 0) {
            vm.expectRevert(abi.encodeWithSelector(KingClaimMistakenETH.InvalidAddress.selector, _alternateAddress));
        }

        // Assign _oneQuadrillionWei.
        uint256 _oneQuadrillionWei = 1e15;

        // Bound _ethAmount to valid ETH range (0.001 ETH to 10 ETH).
        _ethAmount = bound(_ethAmount, _oneQuadrillionWei, STARTING_BALANCE);

        // Fund _userAddress.
        vm.deal(_userAddress, _ethAmount);

        // Prank and deposit as _userAddress.
        vm.prank(_userAddress);
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHDeposited(_userAddress, _ethAmount);
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: _ethAmount}("");
        assertTrue(success);

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Claim as _userAddress.
        vm.prank(_userAddress);
        kingClaimMistakenETH.claimMistakenETHTo(_alternateAddress);

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert _userAddress balance is equal to zero.
        assertEq(kingClaimMistakenETH.userMistakenETHBalance(_userAddress), 0);

        // Assert totalMistakenETH balance before is greater than balance after.
        assertGt(balanceBefore, balanceAfter);
    }

    /// @notice Fuzz test ensuring users cannot claim ETH to the zero or the contract itself.
    /// @param _userAddress The user's address.
    /// @param _alternateAddress The alternate address.
    /// @param _ethAmount The amount of ETH funded or claimed.
    function testFuzz_ClaimMistakenETHTo_RevertsInvalidAddress(
        address _userAddress,
        address _alternateAddress,
        uint256 _ethAmount
    ) external {
        // Assume _alternateAddress is the zero or the kingClaimMistakenETH contract address.
        vm.assume(_alternateAddress == address(0) || _alternateAddress == address(kingClaimMistakenETH));

        // Call private _assume helper function.
        _assume(_userAddress);

        // Assign _oneQuadrillionWei.
        uint256 _oneQuadrillionWei = 1e15;

        // Bound _ethAmount to valid ETH range (0.001 ETH to 10 ETH).
        _ethAmount = bound(_ethAmount, _oneQuadrillionWei, STARTING_BALANCE);

        // Fund _userAddress.
        vm.deal(_userAddress, _ethAmount);

        // Prank and deposit as _userAddress.
        vm.prank(_userAddress);
        vm.expectEmit(true, true, false, false);
        emit KingClaimMistakenETH.MistakenETHDeposited(_userAddress, _ethAmount);
        (bool success,) = payable(address(kingClaimMistakenETH)).call{value: _ethAmount}("");
        assertTrue(success);

        // Assign totalMistakenETH balance before.
        uint256 balanceBefore = kingClaimMistakenETH.totalMistakenETH();

        // Revert `InvalidAddress`, Since alternateAddress is the zero or the kingClaimMistakenETH contract address.
        vm.expectRevert(abi.encodeWithSelector(KingClaimMistakenETH.InvalidAddress.selector, _alternateAddress));
        vm.prank(_userAddress);
        kingClaimMistakenETH.claimMistakenETHTo(_alternateAddress);

        // Assign totalMistakenETH balance after.
        uint256 balanceAfter = kingClaimMistakenETH.totalMistakenETH();

        // Assert _userAddress balance is equal to _ethAmount.
        assertEq(kingClaimMistakenETH.userMistakenETHBalance(_userAddress), _ethAmount);

        // Assert totalMistakenETH balance before is equal to balance after.
        assertEq(balanceBefore, balanceAfter);
    }

    /// @notice Fuzz test to ensure multiple users with zero balance can't claim ETH.
    /// @param _userAddress The user's address.
    function testFuzz_ClaimMistakenETH_RevertsInsufficientFunds(address _userAddress) public {
        // Call private _assume helper function.
        _assume(_userAddress);

        // Revert `InsufficientFunds`.
        vm.expectRevert(KingClaimMistakenETH.InsufficientFunds.selector);
        vm.prank(_userAddress);
        kingClaimMistakenETH.claimMistakenETH();
    }

    // ----------------------------------------------- Fuzz test: Receive & Fallback ---------------------------------

    /// @notice Fuzz test on receive to ensure multiple users can't fund zero ETH to contract.
    /// @param _userAddress The user's address.
    function testFuzz_Receive_RevertsAmountTooLow(address _userAddress) public {
        // Call private _assume helper function.
        _assume(_userAddress);

        // Revert `AmountTooLow`.
        vm.expectRevert(KingClaimMistakenETH.AmountTooLow.selector);
        vm.prank(_userAddress);
        payable(address(kingClaimMistakenETH)).call{value: 0}("");
    }

    /// @notice Fuzz test on fallback to ensure multiple users can't fund zero ETH to contract.
    /// @param _userAddress The user's address.
    function testFuzz_Fallback_RevertsAmountTooLow(address _userAddress) public {
        // Call private _assume helper function.
        _assume(_userAddress);

        // Revert `AmountTooLow`.
        vm.expectRevert(KingClaimMistakenETH.AmountTooLow.selector);
        vm.prank(_userAddress);
        payable(address(kingClaimMistakenETH)).call{value: 0}(
            hex"55241077000000000000000000000000000000000000000000000000000000000000007b"
        );
    }
}
