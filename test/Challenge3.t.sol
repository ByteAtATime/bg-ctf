// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseTest} from "./BaseTest.sol";
import {Challenge3} from "../src/Challenge3.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract CallChallenge3 {
    constructor(Challenge3 challenge3) {
        challenge3.mintFlag();
    }
}

contract Challenge3Test is BaseTest {
    Challenge3 challenge3;

    function setUp() public {
        setUpChallenges();

        challenge3 = new Challenge3(address(nftFlags));
        vm.prank(msg.sender);
        nftFlags.addAllowedMinter(address(challenge3));
    }

    function test_challenge3() public {
        new CallChallenge3(challenge3);
        
        assertTrue(nftFlags.hasMinted(msg.sender, 3));
    }
}
