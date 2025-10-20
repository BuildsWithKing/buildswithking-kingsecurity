// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title RejectETHTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 8th of Oct, 2025.
 *
 *     Test contract for simulating ETH rejection.
 */

/// @notice Imports BaseTest and KingRejectETH contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingRejectETH} from "../../../src/guards/KingRejectETH.sol";

contract KingRejectETHTest is BaseTest {
    // ------------------------------------------ Unit Test: Receive Rejects ETH ---------------------
    /// @notice Test to ensure receive reverts.
    function testRejectETH_ReceiveReverts() public {
        // Revert `ETHRejected`, since the contract rejects ETH.
        vm.expectRevert(KingRejectETH.EthRejected.selector);
        vm.prank(USER2);
        payable(address(kingRejectETH)).call{value: ETH_AMOUNT}("");
    }
    // ------------------------------------------ Unit Test: Fallback Rejects ETH ---------------------
    /// @notice Test to ensure fallback reverts.

    function testRejectETH_FallbackReverts() public {
        // Revert `ETHRejected`, since the contract rejects ETH.
        vm.expectRevert(KingRejectETH.EthRejected.selector);
        vm.prank(USER2);
        payable(address(kingRejectETH)).call{value: ETH_AMOUNT}(
            hex"55641345000000000000000000000000000000000000000000000000000000000000006d"
        );
    }
}
