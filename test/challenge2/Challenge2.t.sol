// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge1} from "../../src/Challenge1.sol";
import {Challenge2} from "../../src/Challenge2.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract CallChallenge2 {
    // intermediary contract: tx.origin would be the player, while msg.sender would be this contract
    function callChallenge2(Challenge2 challenge2) public {
        challenge2.justCallMe();
    }
}

contract Challenge2Test is BaseTest {
    Challenge2 challenge2;

    function setUp() public {
        setUpChallenges();

        challenge2 = new Challenge2(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge2));
    }

    function test_challenge2() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: deploy an intermediary contract to call the challenge
        CallChallenge2 callChallenge2 = new CallChallenge2();
        // Step 2: call the challenge through the intermediary contract
        callChallenge2.callChallenge2(challenge2);

        // DONE: You should have obtained the flag for challenge #2
        assertTrue(nftFlags.hasMinted(address(this), 2));
    }
}
