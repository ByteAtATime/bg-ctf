// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Challenge1} from "../src/Challenge1.sol";
import {NFTFlags} from "../src/NFTFlags.sol";

contract BaseTest is Test {
    Challenge1 challenge1;
    NFTFlags nftFlags;

    address ADMIN; // the address used to deploy the challenges
    address PLAYER; // the address used to interact with the challenges

    function setUpChallenges() internal {
        ADMIN = msg.sender;
        PLAYER = address(this);

        nftFlags = new NFTFlags(ADMIN);
        vm.prank(ADMIN);
        nftFlags.enable();

        challenge1 = new Challenge1(address(nftFlags));
        vm.prank(ADMIN);
        nftFlags.addAllowedMinter(address(challenge1));

       // Register team in challenge #1 (required for subsequent challenges)
        vm.prank(PLAYER);
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