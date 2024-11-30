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

// Step 1: implement a contract that satisfies the interface IContract6Solution
contract CallChallenge6 is IContract6Solution {
    function callChallenge6(Challenge6 challenge6, uint256 code) public {
        challenge6.mintFlag(code);
    }

    // This should return the exact string that is expected by the challenge
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

        // Step 2: calculate the code that will be used to mint the flag
        uint256 count = challenge6.count();
        uint256 code = count << 8;

        // Step 3: call the contract that will mint the flag
        CallChallenge6 callChallenge6 = new CallChallenge6();
        // note the gas limit here, it is important to set it to 200_000
        // the challenge expects from 190,000 to 200,000 gas
        // we set it to 200,000 because the calls will use some gas
        callChallenge6.callChallenge6{ gas: 200_000 }(challenge6, code);

        // DONE: You should have obtained the flag for challenge #6
        assertTrue(nftFlags.hasMinted(PLAYER, 6));
    }
}
