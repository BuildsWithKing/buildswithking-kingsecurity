// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingReentrancyAttackerUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 8th of Oct, 2025.
 *
 *         Unit test contract ensuring KingReentrancyAttacker contract works as intended.
 *  @dev   Here, Base test contract is the attacker.
 */

/// @notice Imports BaseTest, KingReentrancyAttacker and KingVulnerableContract contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingReentrancyAttacker} from "../../../src/utils/KingReentrancyAttacker.sol";
import {KingVulnerableContract} from "../../../src/utils/KingVulnerableContract.sol";

contract KingReentrancyAttackerUnitTest is BaseTest {
    // ----------------------------- Unit Test: Constructor ---------------------------------------------
    /// @notice Test to ensure the zero address can't be set as the target contract.
    function testConstructor_RevertsInvalidAddress() public {
        // Revert `InvalidAddress` since the ZERO address is not a valid contract address.
        vm.expectRevert(abi.encodeWithSelector(KingReentrancyAttacker.InvalidAddress.selector, ZERO));
        kingReentrancyAttacker = new KingReentrancyAttacker(payable(address(ZERO)), MAX_REENTRANCY);
    }

    /// @notice Test to ensure the attacker can't set max reentrancy to zero on deployment.
    function testConstructor_RevertsZeroMaxReentrancy() public {
        // Revert `ZeroMaxReentrancy` since max reentrancy can't be zero.
        vm.expectRevert(abi.encodeWithSelector(KingReentrancyAttacker.ZeroMaxReentrancy.selector, 0));
        kingReentrancyAttacker = new KingReentrancyAttacker(payable(attacker), 0);
    }

    // ----------------------------- Private Helper Function -------------------------------------------
    /// @notice Funds and attack the vulnerable contract.
    function _fundAndAttack() private {
        // Assign oneHundredEther.
        uint256 oneHundredEther = 100 ether;

        // Fund 100 ETH to KingVulnerableContract.
        vm.deal(address(kingVulnerableContract), oneHundredEther);

        // Emit the events AttackStarted, AttackStopped, EthDeposited and attack KingVulnerableContract as the attacker.
        vm.expectEmit(true, true, true, false);
        emit KingReentrancyAttacker.AttackStarted(attacker, address(kingVulnerableContract), ETH_AMOUNT);
        emit KingReentrancyAttacker.AttackStopped(
            attacker, address(kingReentrancyAttacker).balance, address(kingVulnerableContract).balance
        );
        emit KingReentrancyAttacker.EthDeposited(address(kingVulnerableContract), ETH_AMOUNT);
        kingReentrancyAttacker.fundAndAttack{value: ETH_AMOUNT}();
    }

    // ----------------------------- Unit Test: Attacker's Write Functions ------------------------------
    /// @notice Test to ensure the attacker can attack the target contract.
    function testFundAndAttack_Succeeds() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assign fiftyOneEther.
        uint256 fiftyOneEther = 51 ether;

        // Assert kingReentrancyAttacker contract balance is equal to 50 ETH.
        assertEq(kingReentrancyAttacker.contractBalance(), FIFTY_ETHER);

        // Assert kingVulnerableContract contract balance is equal to 51 ETH.
        assertEq(kingVulnerableContract.contractBalance(), fiftyOneEther);
    }

    /// @notice Test to ensure the attacker can't attack with zero ETH.
    function testFundAndAttack_RevertsAmountTooLow() public {
        // Revert `AmountTooLow`, since the attack amount is zero ETH.
        vm.expectRevert(KingReentrancyAttacker.AmountTooLow.selector);
        kingReentrancyAttacker.fundAndAttack{value: 0}();
    }

    /// @notice Test to ensure the attacker can stop an attack.
    function testStopAttack_Succeeds() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Emit the event AttackStopped and stop the attack as the attacker.
        vm.expectEmit(true, true, true, false);
        emit KingReentrancyAttacker.AttackStopped(
            attacker, address(kingReentrancyAttacker).balance, address(kingVulnerableContract).balance
        );
        kingReentrancyAttacker.stopAttack();
    }

    /// @notice Test to ensure the attacker can withdraw ETH from the contract to wallet.
    function testWithdrawETH_Succeeds() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assign fiftyNineEther.
        uint256 fiftyNineEther = 59 ether;

        // Emit the event `EthWithdrawn` and withdraw as the attacker.
        vm.expectEmit(true, true, true, false);
        emit KingReentrancyAttacker.EthWithdrawn(attacker, FIFTY_ETHER, attacker);
        kingReentrancyAttacker.withdrawETH(FIFTY_ETHER, attacker);

        // Assert kingReentrancyAttacker contract balance is equal to zero.
        assertEq(kingReentrancyAttacker.contractBalance(), 0);

        // Assert the attacker's balance is equal to 59 ETH.
        assertEq(attacker.balance, fiftyNineEther);
    }

    /// @notice Test to ensure the attacker can't withdraw to the zero or contract address.
    function testWithdrawETH_RevertsInvalidAddress() public {
        // Call private helper function.
        _fundAndAttack();

        // Revert `InvalidAddress`, since the zero address is not a valid address.
        vm.expectRevert(abi.encodeWithSelector(KingReentrancyAttacker.InvalidAddress.selector, ZERO));
        kingReentrancyAttacker.withdrawETH(FIFTY_ETHER, ZERO);

        // Revert `InvalidAddress`, since the address belongs to the contract.
        vm.expectRevert(
            abi.encodeWithSelector(KingReentrancyAttacker.InvalidAddress.selector, address(kingReentrancyAttacker))
        );
        kingReentrancyAttacker.withdrawETH(FIFTY_ETHER, address(kingReentrancyAttacker));
    }

    /// @notice Test to ensure the attacker can't withdraw ETH to contracts that reject ETH.
    function testWithdrawETH_RevertsWithdrawalFailed() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Revert `WithdrawalFailed`, since the receiving address rejects ETH.
        vm.expectRevert(KingReentrancyAttacker.WithdrawalFailed.selector);
        kingReentrancyAttacker.withdrawETH(FIFTY_ETHER, address(kingRejectETH));

        // Assert kingReentrancyAttacker contract balance is equal to FIFTY_ETHER.
        assertEq(kingReentrancyAttacker.contractBalance(), FIFTY_ETHER);

        // Assert kingRejectETH contract balance is equal to zero.
        assertEq(address(kingRejectETH).balance, 0);
    }

    /// @notice Test to ensure only the attacker can withdraw ETH.
    function testWithdrawETH_RevertsUnauthorized() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Revert `Unauthorized`, since USER2 isn't the attacker.
        vm.expectRevert(abi.encodeWithSelector(KingReentrancyAttacker.Unauthorized.selector, USER2, attacker));
        vm.prank(USER2);
        kingReentrancyAttacker.withdrawETH(FIFTY_ETHER, USER2);

        // Assert kingReentrancyAttacker contract balance is equal to 50 ETH.
        assertEq(kingReentrancyAttacker.contractBalance(), FIFTY_ETHER);
    }

    // -------------------------------------- Unit Test: Attacker's Read Functions -----------------------------------
    /// @notice Test to ensure the attacker can view the contract balance.
    function testContractBalance_Returns() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assert the contract balance is equal to 50 ETH.
        assertEq(kingReentrancyAttacker.contractBalance(), FIFTY_ETHER);
    }

    /// @notice Test to ensure the attacker can view the target contract address.
    function testTargetContract_Returns() public view {
        // Assert target contract is equal to the vulnerable contract's address.
        assertEq(address(kingReentrancyAttacker.targetContract()), address(kingVulnerableContract));
    }

    /// @notice Test to ensure the attacker can view the attack rounds.
    function testAttackRounds_Returns() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assert attack rounds is equal to 50.
        assertEq(kingReentrancyAttacker.attackRounds(), 50);
    }

    /// @notice Test to ensure the attacker can view maximum reentrancy attempt.
    function testMaximumReentrancy_Returns() public view {
        // Assert maximum reentrancy attempt is equal to 50.
        assertEq(kingReentrancyAttacker.maximumReentrancy(), MAX_REENTRANCY);
    }

    /// @notice Test to ensure the attacker can view the attacking address.
    function testAttacker_Returns() public view {
        // Assert attacker is equal to attacker.
        assertEq(kingReentrancyAttacker.attacker(), attacker);
    }

    // ------------------------------------------ Unit Test: Attacker's Receive Function --------------------------------
    /// @notice Test to ensure the receive function stops the attack once the target contract balance is empty.
    function testReceive_StopsAttack_AtZeroTargetBalance() public {
        // Emit the event AttackStarted, AttackStopped and attack KingVulnerableContract as attacker.
        vm.expectEmit(true, true, true, false);
        emit KingReentrancyAttacker.AttackStarted(attacker, address(kingVulnerableContract), ETH_AMOUNT);
        emit KingReentrancyAttacker.AttackStopped(
            attacker, address(kingReentrancyAttacker).balance, address(kingVulnerableContract).balance
        );
        emit KingReentrancyAttacker.EthDeposited(address(kingVulnerableContract), ETH_AMOUNT);
        kingReentrancyAttacker.fundAndAttack{value: ETH_AMOUNT}();

        // Assert kingReentrancyAttacker contract balance is equal to 1 ETH.
        assertEq(kingReentrancyAttacker.contractBalance(), ETH_AMOUNT);

        // Assert target contract balance is equal to zero.
        assertEq(address(kingVulnerableContract).balance, 0);
    }

    // ------------------------------------------- Unit Test: Vulnerable Contract's Write Functions ------------------------
    /// @notice Test to ensure users can't deposit zero ETH.
    function testDepositETH_RevertsAmountTooLow() public {
        // Revert `AmountTooLow`, since the depositing value is zero.
        vm.expectRevert(KingVulnerableContract.AmountTooLow.selector);
        vm.prank(USER2);
        kingVulnerableContract.depositETH{value: 0}();
    }

    /// @notice Test to ensure users can't withdraw ETH greater than their balance.
    function testVulnerableWithdrawETH_RevertsBalanceTooLow() public {
        // Prank and deposit one ETH as USER2.
        vm.prank(USER2);
        kingVulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Revert `BalanceTooLow`, since FIFTY_ETHER is greater than USER2's balance.
        vm.expectRevert(KingVulnerableContract.BalanceTooLow.selector);
        vm.prank(USER2);
        kingVulnerableContract.withdrawETH(FIFTY_ETHER);
    }

    /// @notice Test to ensure withdrawETH reverts when withdrawal fails.
    function testVulnerableWithdrawETH_RevertsWithdrawalFailed() public {
        // Fund 10 ETH to kingRejectETH contract.
        vm.deal(address(kingRejectETH), STARTING_BALANCE);

        // Prank and deposit one ETH as kingRejectETH.
        vm.prank(address(kingRejectETH));
        kingVulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Revert `WithdrawalFailed`, since the receiving address rejects ETH.
        vm.expectRevert(KingVulnerableContract.WithdrawalFailed.selector);
        vm.prank(address(kingRejectETH));
        kingVulnerableContract.withdrawETH(ETH_AMOUNT);

        // Assign nineEther.
        uint256 nineEther = 9 ether;

        // Assert kingVulnerableContract balance is equal to one ETH.
        assertEq(kingVulnerableContract.contractBalance(), ETH_AMOUNT);

        // Assert kingRejectETH contract balance is equal to 9 ETH.
        assertEq(address(kingRejectETH).balance, nineEther);
    }

    // ------------------------------------------- Unit Test: Vulnerable Contract's Read Functions ---------------------------
    /// @notice Test to ensure the attacker can view the contract balance.
    function testVulnerableContractBalance_Returns() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assign fiftyOneEther.
        uint256 fiftyOneEther = 51 ether;

        // Assert vulnerable contract balance is equal to 51 ETH.
        assertEq(kingVulnerableContract.contractBalance(), fiftyOneEther);
    }

    /// @notice Test to ensure the attacker can view their balance on the vulnerable contract.
    function testMyBalance_Returns() public {
        // Call the private `_fundAndAttack` helper function.
        _fundAndAttack();

        // Assert attacker's balance is equal to zero.
        assertEq(kingVulnerableContract.myBalance(), 0);
    }

    /// @notice Test to ensure the attacker can view the owner's address.
    function testOwner_Returns() public view {
        // Assert contract owner is equal to the attacker.
        assertEq(kingVulnerableContract.owner(), attacker);
    }

    // ------------------------------------------- Unit Test: Vulnerable Contract's Receive Function -------------------------
    /// @notice Test to ensure the attacker can deposit ETH via receive.
    function testVulnerableReceive_Succeeds() public {
        // Deposit 1 ETH to the vulnerable contract as the attacker.
        payable(address(kingVulnerableContract)).call{value: ETH_AMOUNT}("");

        // Assert attacker's balance is equal to 1 ETH.
        assertEq(kingVulnerableContract.myBalance(), ETH_AMOUNT);
    }
}
