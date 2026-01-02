// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge4} from "../../../src/season2/Season2Challenge4.sol";

contract Challenge4Solution {
    Season2Challenge4 challenge;

    constructor(Season2Challenge4 _challenge) {
        challenge = _challenge;
    }

    function solve() external {
        challenge.mintFlag();
    }

    // Step 2: Implement a receive function to handle the callback
    receive() external payable {
        // Step 3: When called back, send the expected ETH to the challenge
        if (msg.sender == address(challenge)) {
            (bool success, ) = address(challenge).call{value: 1 gwei}("");
            require(success, "Failed to send ETH");
        }
    }
}

contract Challenge4Test is BaseTest {
    Season2Challenge4 challenge4;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge4 = new Season2Challenge4(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge4));
        vm.stopPrank();
    }

    function test_challenge4() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: Deploy the solution contract with some ETH
        Challenge4Solution solution = new Challenge4Solution(challenge4);
        vm.deal(address(solution), 1 ether);

        // Step 4: Execute the solve function
        solution.solve();

        // DONE: You should have obtained the flag for challenge #4
        assertTrue(nftFlags.hasMinted(PLAYER, 4));
    }
}