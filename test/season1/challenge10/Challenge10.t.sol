// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge9} from "../../../src/season1/Challenge9.sol";
import {NFTFlags} from "../../../src/season1/NFTFlags.sol";

contract Challenge10Test is BaseTest {
    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        Challenge9 challenge9 = new Challenge9(address(nftFlags), bytes32(uint256(1)));
        nftFlags.addAllowedMinter(address(challenge9));

        bytes32 password = vm.load(address(challenge9), bytes32(uint256(1)));
        bytes32 count = vm.load(address(challenge9), bytes32(uint256(2)));

        bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (uint256(count) % 32)) * 8)));
        bytes32 newPassword = password & mask;

        vm.startPrank(PLAYER);
        challenge9.mintFlag(newPassword);

        vm.stopPrank();
    }

    function test_challenge10() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: get the token ID of the challenge 9 flag
        // In this case, because we are only getting the flags of challenge 1 and 9, the token ID is 2
        uint256 data = 2;
        // Step 2: transfer the flag to the contract
        // This will mint the challenge 10 flag and return the challenge 1 flag (in NFTFlags's onERC721Received)
        nftFlags.safeTransferFrom(PLAYER, address(nftFlags), 1, abi.encodePacked(data));

        // DONE: You should have obtained the flag for challenge #10
        assertTrue(nftFlags.hasMinted(PLAYER, 10));
    }
}
