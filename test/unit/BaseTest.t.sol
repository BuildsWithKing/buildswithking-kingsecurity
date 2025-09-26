// SPDX-License-Identifier: MIT

/// @title BaseTest.
/// @author Michealking (@BuildsWithKing)
/// @custom: security-contact buildswithking@gmail.com
/**
 * @notice Created on the 23rd Of Sept, 2025.
 *
 *     Base test contract that imports and deploys all core, extension, and mock contracts.
 *      Provides common setup variables for unit and fuzz tests.
 */
pragma solidity ^0.8.30;

/**
 * @notice Imports Test from forge standard library, KingableEOAs, kingableContracts, KingPausable,
 *             KingablePausable, kingable, KingImmutable, Mocks, and Dummy contract.
 */
import {Test} from "forge-std/Test.sol";
import {KingableEOAs} from "../../src/extensions/KingableEOAs.sol";
import {KingableContracts} from "../../src/extensions/KingableContracts.sol";
import {KingPausable} from "../../src/extensions/KingPausable.sol";
import {KingablePausable} from "../../src/extensions/KingablePausable.sol";
import {Kingable} from "../../src/core/Kingable.sol";
import {KingImmutable} from "../../src/core/KingImmutable.sol";
import {KingableEOAsMockTest} from "../mocks/KingableEOAsMockTest.t.sol";
import {KingableContractsMockTest} from "../mocks/KingableContractsMockTest.t.sol";
import {KingPausableMockTest} from "../mocks/KingPausableMockTest.t.sol";
import {KingablePausableMockTest} from "../mocks/KingablePausableMockTest.t.sol";
import {KingableMockTest} from "../mocks/KingableMockTest.t.sol";
import {KingImmutableMockTest} from "../mocks/KingImmutableMockTest.t.sol";
import {DummyContract} from "./DummyContract.t.sol";

contract BaseTest is Test {
    // ------------------------------------------ Variable assignment -------------------------------------------

    /**
     * @notice Assigns kingableEOAs, kingableContracts,
     *     dummyContract, kingPausable, kingablePausable
     *         kingable and kingImmutable.
     */
    KingableEOAsMockTest internal kingableEOAs;
    KingableContractsMockTest internal kingableContracts;
    DummyContract internal dummyContract;
    KingPausableMockTest internal kingPausable;
    KingablePausableMockTest internal kingablePausable;
    KingableMockTest internal kingable;
    KingImmutable internal kingImmutable;

    /// @notice Assigns _king, _user2, _zero, _newking and _contractKing.
    address internal _king = address(0x5);
    address internal _user2 = address(0x2);
    address internal constant _zero = address(0);
    address internal _newKing = address(0x10);
    address internal _contractKing;

    // --------------------------------------------- SetUp function. --------------------------------------------

    /// @notice This function runs before every other function.
    function setUp() external {
        // Create a new instance of KingableEOAsMockTest.
        kingableEOAs = new KingableEOAsMockTest(_king);

        // Create a new instance of DummyContract.
        dummyContract = new DummyContract();

        // Assign _contractKing.
        _contractKing = address(dummyContract);

        // Create a new instance of KingableContractsMockTest.
        kingableContracts = new KingableContractsMockTest(_contractKing);

        // Create a new instance of KingPausableMockTest.
        kingPausable = new KingPausableMockTest(_king);

        // Create a new instance of KingablePausableMockTest.
        kingablePausable = new KingablePausableMockTest(_king);

        // Create a new instance of KingableMockTest.
        kingable = new KingableMockTest(_king);

        // Create a new instance of KingImmutableMockTest.
        kingImmutable = new KingImmutableMockTest(_king);

        // Label _king, _zero and _newKing.
        vm.label(_king, "KING");
        vm.label(_user2, "USER2");
        vm.label(_zero, "ZERO");
        vm.label(_newKing, "NEWKING");
        vm.label(_contractKing, "CONTRACTKING");
    }
}
