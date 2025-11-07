// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingERC20CappedUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 6th of Nov, 2025.
 *
 *   @dev KingERC20Capped unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, IERC20, KingERC20Capped, KingERC20Errors and KingERC20CappedMockTest contracts.
import {BaseTest} from "../../../BaseTest.t.sol";
import {IERC20} from "../../../../../src/tokens/ERC20/interfaces/IERC20.sol";
import {KingERC20Capped} from "../../../../../src/tokens/ERC20/extensions/KingERC20Capped.sol";
import {KingERC20Errors} from "../../../../../src/tokens/errors/KingERC20Errors.sol";
import {KingERC20CappedMockTest} from "../../../../mocks/KingERC20CappedMockTest.t.sol";

contract KingERC20CappedUnitTest is BaseTest {
    // ----------------------------------------- Unit Test: Constructor ---------------------------------
    /// @notice Test to ensure deployer can't input zero as the token's capped supply.
    function testConstructor_RevertsZeroCaps() public {
        // Revert since the token's cap can't be zero.
        vm.expectRevert(KingERC20Errors.ZeroCap.selector);
        kingERC20Capped = new KingERC20CappedMockTest(KING, KingERC, KERC, ONE_MILLION, 0);
    }

    // -------------------------------------- Unit Test: King and Minter's Write Function -----------------
    /// @notice Test to ensure the king can mint more tokens.
    function testMint_Succeeds() public {
        // Assign twoMillion.
        uint256 twoMillion = 2000000;

        // Create a new instance of KingERC20Capped.
        kingERC20Capped = new KingERC20CappedMockTest(KING, KingERC, KERC, ONE_MILLION, twoMillion);

        // Prank and mint new token as the king.
        vm.prank(KING);
        kingERC20Capped.mint(KING, ONE_MILLION);

        assertEq(kingERC20Capped.totalSupply(), twoMillion);
    }

    /// @notice Test to ensure the king can't mint more tokens.
    function testMint_RevertsCapExceeded() public {
        // Revert since the capped supply is 1,000,000.
        vm.expectRevert(KingERC20Errors.CapExceeded.selector);
        vm.prank(KING);
        kingERC20Capped.mint(KING, ONE_THOUSAND);
    }

    // ------------------------------------------- Unit Test: Read Function ------------------------------
    /// @notice Test to ensure users and the king can view the token's capped supply.
    function testCapped_Returns() public {
        // Assign cap.
        uint256 cap = kingERC20Capped.cap();

        // assert token's capped supply is equal to 1,000,000.
        assertEq(cap, ONE_MILLION);
    }
}
