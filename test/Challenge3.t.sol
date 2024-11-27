// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Challenge1} from "../src/Challenge1.sol";
import {Challenge3} from "../src/Challenge3.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract CallChallenge3 {
    constructor(Challenge3 challenge3) {
        challenge3.mintFlag();
    }
}

contract Challenge3Test is Test {
    Challenge3 challenge3;
    NFTFlags nftFlags;

    function setUp() public {
        nftFlags = new NFTFlags(msg.sender);
        vm.prank(msg.sender);
        nftFlags.enable();

        Challenge1 challenge1 = new Challenge1(address(nftFlags));
        vm.prank(msg.sender);
        nftFlags.addAllowedMinter(address(challenge1));
        vm.prank(msg.sender);
        challenge1.registerTeam("Team Name", 2);

        challenge3 = new Challenge3(address(nftFlags));
        vm.prank(msg.sender);
        nftFlags.addAllowedMinter(address(challenge3));
    }

    function test_challenge3() public {
        new CallChallenge3(challenge3);
        
        assertTrue(nftFlags.hasMinted(msg.sender, 3));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
