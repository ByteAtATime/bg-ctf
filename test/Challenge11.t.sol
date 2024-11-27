// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "./BaseTest.sol";
import {Challenge11} from "../src/Challenge11.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

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
            CallChallenge11 caller = new CallChallenge11();

            uint8 senderLastByte = uint8(abi.encodePacked(PLAYER)[19]);
            uint8 originLastByte = uint8(abi.encodePacked(address(caller))[19]);

            if ((senderLastByte & 0x15) == (originLastByte & 0x15)) {
                caller.callChallenge11(challenge11);
                break;
            }
        }

        assertTrue(nftFlags.hasMinted(PLAYER, 11));
    }
}
