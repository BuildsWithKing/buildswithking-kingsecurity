// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20UnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 5th of Nov, 2025.
 *
 *     KingERC20 unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, IERC20, KingERC20, KingERC20Errors, KingERC20MockTest contracts.
import {BaseTest} from "../../BaseTest.t.sol";
import {IERC20} from "../../../../src/tokens/ERC20/interfaces/IERC20.sol";
import {KingERC20} from "../../../../src/tokens/ERC20/KingERC20.sol";
import {KingERC20Errors} from "../../../../src/tokens/errors/KingERC20Errors.sol";
import {KingERC20MockTest} from "../../../mocks/KingERC20MockTest.t.sol";

contract KingERC20UnitTest is BaseTest {
    // -------------------------------------------------- Unit Test: Constructor -------------------------------------
    /// @notice Test to ensure the constructor sets the king, token details and assigns initial supply to the king at deployment.
    function testConstructor_Succeeds() public {
        // Assert the king is equal to King.
        assertEq(kingERC20.s_king(), KING);

        // Assert the token's name is equal to KingERC.
        assertEq(kingERC20.name(), KingERC);

        // Assert the token's symbol is equal to KERC.
        assertEq(kingERC20.symbol(), KERC);

        // Assert the token's total supply is equal to 1,000,000.
        assertEq(kingERC20.totalSupply(), ONE_MILLION);

        // Assert the king's balance is equal to 1,000,000.
        assertEq(kingERC20.balanceOf(KING), ONE_MILLION);
    }

    /// @notice Test to ensure the constructor reverts for zero address as the king.
    function testConstructor_Reverts() public {
        // Revert since the zero address is not a valid king address.
        vm.expectRevert();
        kingERC20 = new KingERC20MockTest(ZERO, KingERC, KERC, ONE_MILLION);
    }

    /// @notice Test to ensure the deployer can't input zero as the token's initial supply.
    function testConstructor_RevertsZeroInitialSupply() public {
        // Revert since the token can't have a zero initial supply.
        vm.expectRevert(KingERC20Errors.ZeroInitialSupply.selector);
        kingERC20 = new KingERC20MockTest(KING, KingERC, KERC, 0);
    }

    // -------------------------------------------------- Unit Test: Write Functions ----------------------------------------
    /// @notice Test to ensure the king and users can transfer token to another user.
    function testTransfer_Succeeds() public {
        // Assign nnineHundredAndNinetyNineThousand.
        uint64 nineHundredAndNinetyNineThousand = 999000;

        // Emit the event Transfer and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Transfer(KING, USER2, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.transfer(USER2, ONE_THOUSAND);

        // Assert the king's token balance is equal to 999,000.
        assertEq(kingERC20.balanceOf(KING), nineHundredAndNinetyNineThousand);

        // Assert user2's balance is equal to 1,000.
        assertEq(kingERC20.balanceOf(USER2), ONE_THOUSAND);
    }

    /// @notice Test to ensure users with zero balance can't transfer token.
    function testTransfer_RevertsInsufficientBalance() public {
        // Revert since user1's balance is not upto 1,000.
        vm.expectRevert(
            abi.encodeWithSelector(KingERC20Errors.InsufficientBalance.selector, kingERC20.balanceOf(USER1))
        );
        vm.prank(USER1);
        kingERC20.transfer(USER2, ONE_THOUSAND);
    }

    /// @notice Test to ensure the king or users can't transfer token to the zero address.
    function testTransfer_Reverts() public {
        // Revert since the token receiver is the zero address.
        vm.expectRevert();
        vm.prank(KING);
        kingERC20.transfer(ZERO, ONE_THOUSAND);
    }

    /// @notice Test to ensure the king and users can approve token to be spent by another user.
    function testApprove_Succeds() public {
        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, USER1, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.approve(USER1, ONE_THOUSAND);

        // Assert user1's allowance is equal to 1,000.
        assertEq(kingERC20.allowance(KING, USER1), ONE_THOUSAND);
    }

    /// @notice Test to ensure the king or users can't approve the zero address to spend on their behalf.
    function testApprove_Reverts() public {
        // Revert since the address is the zero address.
        vm.expectRevert();
        vm.prank(KING);
        kingERC20.approve(ZERO, ONE_THOUSAND);
    }

    /// @notice Test to ensure the spender can spend token on behalf of the owner.
    function testTransferFrom_Succeeds() public {
        // Assign nineHundredAndNinetyNineThousand.
        uint64 nineHundredAndNinetyNineThousand = 999000;

        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, USER1, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.approve(USER1, ONE_THOUSAND);

        // Emit the event Transfer and prank as user1.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Transfer(KING, USER1, ONE_THOUSAND);
        vm.prank(USER1);
        kingERC20.transferFrom(KING, USER1, ONE_THOUSAND);

        // assert user1's balance is equal to 1,000.
        assertEq(kingERC20.balanceOf(USER1), ONE_THOUSAND);

        // Assert the king's token balance is equal to 999,000.
        assertEq(kingERC20.balanceOf(KING), nineHundredAndNinetyNineThousand);
    }

    /// @notice Test to ensure the spender can't spend token greater than their allowance.
    function testTransferFrom_RevertsInsufficientAllowance() public {
        // Assign tenThousand.
        uint64 tenThousand = 10000;

        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, USER2, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.approve(USER2, ONE_THOUSAND);

        // Revert since user2's allowance is not upto 10,000.
        vm.expectRevert(
            abi.encodeWithSelector(KingERC20Errors.InsufficientAllowance.selector, kingERC20.allowance(KING, USER2))
        );
        vm.prank(USER2);
        kingERC20.transferFrom(KING, USER2, tenThousand);
    }

    // ---------------------------------------------------- Unit Test: Read Functions -----------------------------------------------
    /// @notice Test to ensure users can view the token's total supply.
    function testTotalSupply_Returns() public {
        // Assert the token's total supply is equal to 1,000,000.
        assertEq(kingERC20.totalSupply(), ONE_MILLION);
    }

    /// @notice Test to ensure users can view the token's name.
    function testName_Returns() public {
        // Assert the token's name is KingERC.
        assertEq(kingERC20.name(), KingERC);
    }

    /// @notice Test to ensure users can view the token's symbol.
    function testSymbol_Returns() public {
        // Assert the token's symbol is KERC.
        assertEq(kingERC20.symbol(), KERC);
    }

    /// @notice Test to ensure users can view the token's decimal.
    function testDecimals_Returns() public {
        // Assert the token's decimal is 18.
        assertEq(kingERC20.decimals(), 18);
    }

    /// @notice Test to ensure users can view their token balance or that of other users.
    function testBalanceOf_Returns() public {
        // Emit the event Transfer and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Transfer(KING, USER2, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.transfer(USER2, ONE_THOUSAND);

        // Prank as user2 and assign myBalance.
        vm.prank(USER2);
        uint256 myBalance = kingERC20.balanceOf(USER2);

        // Assert user2's balance is equal to 1,000.
        assertEq(myBalance, ONE_THOUSAND);
    }

    /// @notice Test to ensure users can view their allowance.
    function testAllowance_Returns() public {
        // Emit the event Approval and prank as the king.
        vm.expectEmit(true, true, true, false);
        emit IERC20.Approval(KING, USER1, ONE_THOUSAND);
        vm.prank(KING);
        kingERC20.approve(USER1, ONE_THOUSAND);

        // Prank as user1 and assign myAllowance.
        vm.prank(USER1);
        uint256 myAllowance = kingERC20.allowance(KING, USER1);

        // Assert user1's allowance is equal to 1,000.
        assertEq(myAllowance, ONE_THOUSAND);
    }
}
