// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge3} from "../../../src/season2/Season2Challenge3.sol";

// Step 1: Create an intermediary contract that implements the required interface
contract Challenge3Solution {
    function accessKey() external pure returns (string memory) {
        return "LET_ME_IN";
    }

    function solve(Season2Challenge3 challenge) external {
        challenge.mintFlag();
    }
}

contract Challenge3Test is BaseTest {
    Season2Challenge3 challenge3;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge3 = new Season2Challenge3(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge3));
        vm.stopPrank();
    }

    function test_challenge3() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 2: Deploy the solution contract
        Challenge3Solution solution = new Challenge3Solution();

        // Step 3: Call the solve function on the solution contract
        solution.solve(challenge3);

        // DONE: You should have obtained the flag for challenge #3
        assertTrue(nftFlags.hasMinted(PLAYER, 3));
    }
}
