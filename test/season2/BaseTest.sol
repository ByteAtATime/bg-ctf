// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTFlags} from "../../src/season1/NFTFlags.sol";
import {Season2NFTFlags} from "../../src/season2/Season2NFTFlags.sol";
import {Challenge1} from "../../src/season1/Challenge1.sol";

contract BaseTest is Test {
    NFTFlags season1NftFlags;
    Season2NFTFlags nftFlags;
    Challenge1 s1Challenge1;

    address ADMIN;
    address PLAYER;

    function setUpChallenges() internal {
        ADMIN = msg.sender;
        PLAYER = address(this);

        // Setup Season 1
        season1NftFlags = new NFTFlags(ADMIN);
        vm.startPrank(ADMIN);
        season1NftFlags.enable();
        s1Challenge1 = new Challenge1(address(season1NftFlags));
        season1NftFlags.addAllowedMinter(address(s1Challenge1));
        vm.stopPrank();

        // Register Player in Season 1 (required for S2 minting)
        vm.prank(PLAYER);
        s1Challenge1.registerTeam("Team Name", 2);

        // Setup Season 2
        vm.startPrank(ADMIN);
        nftFlags = new Season2NFTFlags(ADMIN, address(season1NftFlags));
        nftFlags.enable();
        vm.stopPrank();
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
