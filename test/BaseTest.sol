// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Challenge1} from "../src/Challenge1.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract BaseTest is Test {
    Challenge1 challenge1;
    NFTFlags nftFlags;

    function setUpChallenges() internal {
        nftFlags = new NFTFlags(msg.sender);
        vm.prank(msg.sender);
        nftFlags.enable();

        challenge1 = new Challenge1(address(nftFlags));
        vm.prank(msg.sender);
        nftFlags.addAllowedMinter(address(challenge1));

       // Register team in challenge #1 (required for subsequent challenges)
        vm.prank(msg.sender);
        challenge1.registerTeam("Team Name", 2);
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