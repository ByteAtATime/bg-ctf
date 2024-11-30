// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge9} from "../../src/Challenge9.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract Challenge9Test is BaseTest {
    Challenge9 challenge9;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        challenge9 = new Challenge9(address(nftFlags), bytes32(uint256(1)));
        nftFlags.addAllowedMinter(address(challenge9));

        vm.stopPrank();
    }

    function test_challenge9() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: read the password and count
        // these are Foundry-specific methods, but the same can be done with other libraries (such as viem's getStorageAt)
        bytes32 password = vm.load(address(challenge9), bytes32(uint256(1)));
        bytes32 count = vm.load(address(challenge9), bytes32(uint256(2)));

        // Step 2: mask the password
        // This is the exact same code as in the contract
        bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (uint256(count) % 32)) * 8)));
        bytes32 newPassword = password & mask;

        // Step 3: mint the flag
        challenge9.mintFlag(newPassword);

        // DONE: You should have obtained the flag for challenge #9
        assertTrue(nftFlags.hasMinted(PLAYER, 9));
    }
}
