// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge2} from "../../../src/season2/Season2Challenge2.sol";

contract Challenge2Test is BaseTest {
    Season2Challenge2 challenge2;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge2 = new Season2Challenge2(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge2));
        vm.stopPrank();
    }

    function test_challenge2() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: Calculate the key using the player's address and the contract's address (same logic as the contract)
        bytes32 key = keccak256(abi.encodePacked(PLAYER, address(challenge2)));

        // Step 2: Call mintFlag with the calculated key
        challenge2.mintFlag(key);

        // DONE: Yay, you did it!
        assertTrue(nftFlags.hasMinted(PLAYER, 2));
    }
}
