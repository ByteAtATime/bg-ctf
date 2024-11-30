// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge6} from "../../src/Challenge6.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

interface IContract6Solution {
    function name() external view returns (string memory);
}

contract CallChallenge6 is IContract6Solution {
    function callChallenge6(Challenge6 challenge6, uint256 code) public {
        challenge6.mintFlag(code);
    }

    function name() external view override returns (string memory) {
        return "BG CTF Challenge 6 Solution";
    }
}

contract Challenge6Test is BaseTest {
    Challenge6 challenge6;

    function setUp() public {
        setUpChallenges();

        vm.prank(ADMIN);
        challenge6 = new Challenge6(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge6));
    }

    function test_challenge6() public {
        vm.startPrank(PLAYER, PLAYER);

        uint256 count = challenge6.count();
        uint256 code = count << 8;

        CallChallenge6 callChallenge6 = new CallChallenge6();
        callChallenge6.callChallenge6{ gas: 200_000 }(challenge6, code);

        assertTrue(nftFlags.hasMinted(PLAYER, 6));
    }
}
