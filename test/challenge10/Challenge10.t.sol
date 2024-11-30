// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge9} from "../../src/Challenge9.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract Challenge10Test is BaseTest {
    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        Challenge9 challenge9 = new Challenge9(address(nftFlags), bytes32(uint256(1)));
        nftFlags.addAllowedMinter(address(challenge9));

        bytes32 password = vm.load(address(challenge9), bytes32(uint256(1)));
        bytes32 count = vm.load(address(challenge9), bytes32(uint256(2)));

        bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (uint256(count) % 32)) * 8)));
        bytes32 newPassword = password & mask;

        vm.startPrank(PLAYER);
        challenge9.mintFlag(newPassword);

        vm.stopPrank();
    }

    function test_challenge10() public {
        vm.startPrank(PLAYER, PLAYER);

        uint256 data = 2;
        nftFlags.safeTransferFrom(PLAYER, address(nftFlags), 1, abi.encodePacked(data));

        assertTrue(nftFlags.hasMinted(PLAYER, 10));
    }
}
