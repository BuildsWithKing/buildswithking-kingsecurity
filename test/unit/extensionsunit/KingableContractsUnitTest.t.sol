// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title KingableContractsUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice Created on the 23rd of Sept, 2025.
 *
 *    KingableContracts unit test contract, verifying all features works as intended.
 */

/// @notice Imports BaseTest, KingableContracts, and KingableContractsMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingableContracts} from "../../../src/extensions/KingableContracts.sol";
import {KingableContractsMockTest} from "../../mocks/KingableContractsMockTest.t.sol";

contract KingableContractsUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ------------------------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() public view {
        // Assign _currentKing.
        address _currentKing = kingableContracts.currentKing();

        // Assert both are equal.
        assertEq(CONTRACTKING, _currentKing);
    }

    /// @notice Test to ensure constructor emits the KingshipTransferred event.
    function testConstructor_EmitsEvent() public {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(ZERO, CONTRACTKING);
        kingableContracts = new KingableContractsMockTest(CONTRACTKING);
    }

    /// @notice Test to ensure address zero revert.
    function testZeroAddress_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, ZERO));
        kingableContracts = new KingableContractsMockTest(ZERO);
    }

    /// @notice Test to ensure EOAs revert.
    function testEOAs_RevertsIfSetAsInitialKing() public {
        // Revert `InvalidKing`, if EOAs is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, KING));
        kingableContracts = new KingableContractsMockTest(KING);
    }

    // ----------------------------------------------------- Test for king's write functions. -----------------------------

    /// @notice Test to ensure CONTRACTKING can transfer kingship to another contract.
    function testTransferKingship_Succeeds() public {
        // Prank as dummyContract.
        vm.prank(CONTRACTKING);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(CONTRACTKING, address(this));
        kingableContracts.transferKingshipTo(address(this));

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, CONTRACTKING, address(this)));
        vm.prank(CONTRACTKING);
        kingableContracts.transferKingshipTo(address(this));
    }

    /// @notice Test to ensure CONTRACTKING can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() public {
        // Revert`SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.SameKing.selector, CONTRACTKING));
        vm.prank(CONTRACTKING);
        kingableContracts.transferKingshipTo(CONTRACTKING);

        // Assert current king is still CONTRACTKING.
        assertEq(kingableContracts.currentKing(), CONTRACTKING);
    }

    /// @notice Test to ensure CONTRACTKING can't transfer kingship to EOAs (humans).
    function testTransferKingship_RevertsInvalidKing() public {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, NEWKING));
        vm.prank(CONTRACTKING);
        kingableContracts.transferKingshipTo(NEWKING);

        // Assert current king is still dummyContract.
        assertEq(kingableContracts.currentKing(), CONTRACTKING);
    }

    /// @notice Test to ensure only CONTRACTKING can transfer kingship.
    function testTransferKingship_RevertsUnauthorized() public {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, USER2, CONTRACTKING));
        vm.prank(USER2);
        kingableContracts.transferKingshipTo(NEWKING);

        // Assert current king is still dummyContract.
        assertEq(kingableContracts.currentKing(), CONTRACTKING);
    }

    /// @notice Test to ensure CONTRACTKING can renounce kingship.
    function testRenounceKingship_Succeeds() public {
        // Prank as CONTRACTKING.
        vm.prank(CONTRACTKING);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(CONTRACTKING, ZERO);
        kingableContracts.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, CONTRACTKING, ZERO));
        vm.prank(CONTRACTKING);
        kingableContracts.renounceKingship();
    }

    // --------------------------------------------------- Users test read functions. --------------------------------------

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing() public view {
        // Assign isKing.
        bool isKing = kingableContracts.isKing(KING);
        bool king = kingableContracts.isKing(CONTRACTKING);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
