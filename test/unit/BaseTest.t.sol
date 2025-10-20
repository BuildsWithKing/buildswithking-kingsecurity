// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title BaseTest.
/// @author Michealking (@BuildsWithKing)
/// @custom:securitycontact buildswithking@gmail.com
/**
 * @notice  Created on the 23rd of Sept, 2025.
 *
 * @dev     This Base test contract imports and deploys all core, extension, and mock contracts.
 *          Provides common setup variables for unit and fuzz tests.
 */

/**
 * @notice  Imports Test from forge standard library, KingableEOAs, kingableContracts, KingPausable,
 *          KingablePausable, kingable, KingImmutable, RejectETH, KingClaimMistakenETH,
 *          KingReentrancyAttacker, VulnerableContract, Mocks, and Dummy contract.
 */
import {Test} from "forge-std/Test.sol";
import {KingableEOAs} from "../../src/extensions/KingableEOAs.sol";
import {KingableContracts} from "../../src/extensions/KingableContracts.sol";
import {KingPausable} from "../../src/extensions/KingPausable.sol";
import {KingablePausable} from "../../src/extensions/KingablePausable.sol";
import {Kingable} from "../../src/core/Kingable.sol";
import {KingImmutable} from "../../src/core/KingImmutable.sol";
import {KingRejectETH} from "../../src/guards/KingRejectETH.sol";
import {KingClaimMistakenETH} from "../../src/guards/KingClaimMistakenETH.sol";
import {KingReentrancyAttacker} from "../../src/utils/KingReentrancyAttacker.sol";
import {KingVulnerableContract} from "../../src/utils/KingVulnerableContract.sol";
import {KingableEOAsMockTest} from "../mocks/KingableEOAsMockTest.t.sol";
import {KingableContractsMockTest} from "../mocks/KingableContractsMockTest.t.sol";
import {KingPausableMockTest} from "../mocks/KingPausableMockTest.t.sol";
import {KingablePausableMockTest} from "../mocks/KingablePausableMockTest.t.sol";
import {KingableMockTest} from "../mocks/KingableMockTest.t.sol";
import {KingImmutableMockTest} from "../mocks/KingImmutableMockTest.t.sol";
import {KingRejectETHMockTest} from "../mocks/KingRejectETHMockTest.t.sol";
import {KingClaimMistakenETHMockTest} from "../mocks/KingClaimMistakenETHMockTest.t.sol";
import {DummyContract} from "./DummyContract.t.sol";

contract BaseTest is Test {
    // ------------------------------------------ State Variable --------------------------------------
    /**
     * @notice  Assigns kingableEOAs, kingableContracts,
     *          dummyContract, kingPausable, kingablePausable
     *          kingable, kingImmutable, kingRejectETH, KingClaimMistakenETH, KingReentrancyAttacker and KingVulnerableContract.
     */
    KingableEOAsMockTest internal kingableEOAs;
    KingableContractsMockTest internal kingableContracts;
    DummyContract internal dummyContract;
    KingPausableMockTest internal kingPausable;
    KingablePausableMockTest internal kingablePausable;
    KingableMockTest internal kingable;
    KingImmutable internal kingImmutable;
    KingRejectETHMockTest internal kingRejectETH;
    KingClaimMistakenETHMockTest internal kingClaimMistakenETH;
    KingReentrancyAttacker internal kingReentrancyAttacker;
    KingVulnerableContract internal kingVulnerableContract;

    /// @notice Assigns KING, USER1, USER2, ZERO, NEWKING, CONTRACTKING and attacker.
    address internal constant KING = address(0x5);
    address internal constant USER1 = address(0x1);
    address internal constant USER2 = address(0x2);
    address internal constant ZERO = address(0);
    address internal constant NEWKING = address(0x10);
    address internal CONTRACTKING;
    address internal attacker = address(this);

    /// @notice Assigns STARTING_BALANCE, ETH_AMOUNT, MAX_REENTRANCY and FIFTY_ETHER.
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant ETH_AMOUNT = 1 ether;
    uint8 internal constant MAX_REENTRANCY = 50;
    uint256 internal constant FIFTY_ETHER = 50 ether;

    // --------------------------------------------- SetUp Function -------------------------------------
    /// @notice This function runs before every other function.
    function setUp() public {
        // Create a new instance of KingableEOAsMockTest.
        kingableEOAs = new KingableEOAsMockTest(KING);

        // Create a new instance of DummyContract.
        dummyContract = new DummyContract();

        // Assign CONTRACTKING.
        CONTRACTKING = address(dummyContract);

        // Create a new instance of KingableContractsMockTest.
        kingableContracts = new KingableContractsMockTest(CONTRACTKING);

        // Create a new instance of KingPausableMockTest.
        kingPausable = new KingPausableMockTest(KING);

        // Create a new instance of KingablePausableMockTest.
        kingablePausable = new KingablePausableMockTest(KING);

        // Create a new instance of KingableMockTest.
        kingable = new KingableMockTest(KING);

        // Create a new instance of KingImmutableMockTest.
        kingImmutable = new KingImmutableMockTest(KING);

        // Create a new instance of KingRejectETHMockTest.
        kingRejectETH = new KingRejectETHMockTest();

        // Create a new instance of KingClaimMistakenETHMockTest.
        kingClaimMistakenETH = new KingClaimMistakenETHMockTest();

        // Create a new instance of KingVulnerableContract.
        kingVulnerableContract = new KingVulnerableContract();

        // Create a new instance of KingReentrancyAttacker.
        kingReentrancyAttacker = new KingReentrancyAttacker(payable(address(kingVulnerableContract)), MAX_REENTRANCY);

        // Label KING, USER2, ZERO, NEWKING, CONTRACTKING and ATTACKER.
        vm.label(KING, "KING");
        vm.label(USER2, "USER2");
        vm.label(ZERO, "ZERO");
        vm.label(NEWKING, "NEWKING");
        vm.label(CONTRACTKING, "CONTRACTKING");
        vm.label(attacker, "ATTACKER");

        // Fund USER2, CONTRACTKING & attacker 10 ETH EACH.
        vm.deal(USER2, STARTING_BALANCE);
        vm.deal(CONTRACTKING, STARTING_BALANCE);
        vm.deal(attacker, STARTING_BALANCE);
    }

    // --------------------------------------------- Receive Function -----------------------------------
    /// @notice Handles ETH Deposit with no calldata for KingReentrancyAttackerUnitTest.
    receive() external payable {}
}
