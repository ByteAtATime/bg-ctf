// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "./BaseTest.sol";
import {Challenge1} from "../src/Challenge1.sol";
import {Challenge2} from "../src/Challenge2.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract CallChallenge2 {
    function callChallenge2(Challenge2 challenge2) public {
        challenge2.justCallMe();
    }
}

contract Challenge2Test is BaseTest {
    Challenge2 challenge2;

    function setUp() public {
        setUpChallenges();

        challenge2 = new Challenge2(address(nftFlags));
        vm.prank(msg.sender);
        nftFlags.addAllowedMinter(address(challenge2));
    }

    function test_challenge2() public {
        CallChallenge2 callChallenge2 = new CallChallenge2();
        callChallenge2.callChallenge2(challenge2);
        
        assertTrue(nftFlags.hasMinted(msg.sender, 2));
    }
}
