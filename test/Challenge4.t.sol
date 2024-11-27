// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "./BaseTest.sol";
import {Challenge4} from "../src/Challenge4.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract Challenge4Test is BaseTest {
    using MessageHashUtils for bytes32;

    Challenge4 challenge4;
    address MINTER = 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a; // address used in actual challenge
    uint256 MINTER_PRIVATE_KEY = 0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1;

    function setUp() public {
        setUpChallenges();

        vm.prank(ADMIN);
        challenge4 = new Challenge4(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge4));

        vm.prank(ADMIN);
        challenge4.addMinter(MINTER);
    }

    function test_challenge4() public {
        vm.startPrank(PLAYER, PLAYER);

        bytes32 message = keccak256(abi.encode("BG CTF Challenge 4", PLAYER));
        bytes32 hash = message.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(MINTER_PRIVATE_KEY, hash);

        challenge4.mintFlag(MINTER, abi.encodePacked(r, s, v));

        assertTrue(nftFlags.hasMinted(PLAYER, 4));
    }
}
