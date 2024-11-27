// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Challenge1} from "../src/Challenge1.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract Challenge1Test is Test {
    Challenge1 challenge1;
    NFTFlags nftFlags;

    address ADMIN;
    address PLAYER;

    function setUp() public {
        ADMIN = msg.sender;
        PLAYER = address(this);

        nftFlags = new NFTFlags(ADMIN);
        vm.prank(ADMIN);
        nftFlags.enable();
        
        challenge1 = new Challenge1(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge1));
    }

    function test_challenge1() public {
        vm.startPrank(PLAYER, PLAYER);
        
        challenge1.registerTeam("Team Name", 2);
        
        assertTrue(nftFlags.hasMinted(PLAYER, 1));
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
