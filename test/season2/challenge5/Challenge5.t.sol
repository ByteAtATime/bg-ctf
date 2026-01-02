// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge5} from "../../../src/season2/Season2Challenge5.sol";

contract Challenge5Test is BaseTest {
    Season2Challenge5 challenge5;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge5 = new Season2Challenge5(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge5));
        vm.stopPrank();
    }

    function test_challenge5() public {
        vm.startPrank(PLAYER, PLAYER);

        uint256 targetCounter = nftFlags.tokenIdCounter();

        // Step 1: Satisfy counter2 condition (tokenIdCounter % 0x80)
        // mload(data2) loads the length of the dynamic array
        uint256 length2 = targetCounter % 0x80;
        uint256[] memory data2 = new uint256[](length2);

        // Step 2: Satisfy counter1 condition (tokenIdCounter)
        // mload(add(data1, 0xD0)) reads 32 bytes starting at offset 208
        // 208 = 32 (length) + 32*5 (index 5) + 16 (halfway)
        // It reads the lower 16 bytes of index 5 and upper 16 bytes of index 6
        uint256[] memory data1 = new uint256[](7); // Need enough space
        
        // We want the result to be `targetCounter` (which is small, so it fits in the lower bits of the 32-byte word)
        // The result word is composed of: [lower 16 bytes of data1[5]] + [upper 16 bytes of data1[6]]
        // Since Result is standard Big Endian uint256, the [lower 16 bytes of data1[5]] become the High bits of Result.
        // The [upper 16 bytes of data1[6]] become the Low bits of Result.
        // We want Result to be `targetCounter` (small number), so High bits should be 0.
        // Low bits should be `targetCounter`.
        
        // 1. data1[5]'s lower 16 bytes should be 0
        data1[5] = 0; 
        
        // 2. data1[6]'s upper 16 bytes should contain `targetCounter`
        // Since `targetCounter` is a uint256, to put it in the upper 128 bits (16 bytes), we shift left.
        data1[6] = targetCounter << 128;

        // Step 3: Call mintFlag
        challenge5.mintFlag(data1, data2);

        // DONE: You should have obtained the flag for challenge #5
        assertTrue(nftFlags.hasMinted(PLAYER, 5));
    }
}