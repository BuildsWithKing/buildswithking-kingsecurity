// SPDX-License-Identifier: MIT

/// @title KingableContractsUnitTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 23rd of Sept, 2025.
 *
 *    KingableContracts unit test contract, verifying all features works as intended.
 */
pragma solidity ^0.8.30;

/// @notice Imports BaseTest, KingableContracts, and KingableContractsMockTest contract.
import {BaseTest} from "../BaseTest.t.sol";
import {KingableContracts} from "../../../src/extensions/KingableContracts.sol";
import {KingableContractsMockTest} from "../../mocks/KingableContractsMockTest.t.sol";

contract KingableContractsUnitTest is BaseTest {
    // ------------------------------------------------- Constructor test functions. ------------------------------------------

    /// @notice Test to ensure constructor sets initial king at deployment.
    function testConstructor_SetsKingAtDeployment() external view {
        // Assign _currentKing.
        address _currentKing = kingableContracts.currentKing();

        // Assert both are equal.
        assertEq(_contractKing, _currentKing);
    }

    /// @notice Test to ensure constructor emits the KingshipTransferred event.
    function testConstructor_EmitsEvent() external {
        // Emit `KingshipTransferred`.
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(_zero, _contractKing);
        kingableContracts = new KingableContractsMockTest(_contractKing);
    }

    /// @notice Test to ensure address zero revert.
    function testZeroAddress_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if address zero is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, _zero));
        kingableContracts = new KingableContractsMockTest(_zero);
    }

    /// @notice Test to ensure EOAs revert.
    function testEOAs_RevertsIfSetAsInitialKing() external {
        // Revert `InvalidKing`, if EOAs is set as initial king.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, _king));
        kingableContracts = new KingableContractsMockTest(_king);
    }

    // ----------------------------------------------------- Test for king's write functions. -----------------------------

    /// @notice Test to ensure _contractKing can transfer kingship to another contract.
    function testTransferKingship_Succeeds() external {
        // Prank as dummyContract.
        vm.prank(_contractKing);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipTransferred(_contractKing, address(this));
        kingableContracts.transferKingshipTo(address(this));

        // Revert Unauthorized.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _contractKing, address(this)));
        vm.prank(_contractKing);
        kingableContracts.transferKingshipTo(address(this));
    }

    /// @notice Test to ensure _contractKing can't transfer kingship to self.
    function testTransferKingship_RevertsIfSelf() external {
        // Revert`SameKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.SameKing.selector, _contractKing));
        vm.prank(_contractKing);
        kingableContracts.transferKingshipTo(_contractKing);

        // Assert current king is still _contractKing.
        assertEq(kingableContracts.currentKing(), _contractKing);
    }

    /// @notice Test to ensure _contractKing can't transfer kingship to EOAs (humans).
    function testTransferKingship_RevertsInvalidKing() external {
        // Revert `InvalidKing`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.InvalidKing.selector, _newKing));
        vm.prank(_contractKing);
        kingableContracts.transferKingshipTo(_newKing);

        // Assert current king is still dummyContract.
        assertEq(kingableContracts.currentKing(), _contractKing);
    }

    /// @notice Test to ensure only _contractKing can transfer kingship.
    function testTransferKingship_RevertsUnauthorized() external {
        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _user2, _contractKing));
        vm.prank(_user2);
        kingableContracts.transferKingshipTo(_newKing);

        // Assert current king is still dummyContract.
        assertEq(kingableContracts.currentKing(), _contractKing);
    }

    /// @notice Test to ensure _contractKing can renounce kingship.
    function testRenounceKingship_Succeeds() external {
        // Prank as _contractKing.
        vm.prank(_contractKing);
        vm.expectEmit(true, true, false, false);
        emit KingableContracts.KingshipRenounced(_contractKing, _zero);
        kingableContracts.renounceKingship();

        // Revert `Unauthorized`.
        vm.expectRevert(abi.encodeWithSelector(KingableContracts.Unauthorized.selector, _contractKing, _zero));
        vm.prank(_contractKing);
        kingableContracts.renounceKingship();
    }

    // --------------------------------------------------- Users test read functions. --------------------------------------

    /// @notice Test to ensure isKing returns  `true` or `false`.
    function testIsKing() external view {
        // Assign isKing.
        bool isKing = kingableContracts.isKing(_king);
        bool king = kingableContracts.isKing(_contractKing);

        // Assert both are equal.
        assertEq(isKing, false);
        assertEq(king, true);
    }
}
