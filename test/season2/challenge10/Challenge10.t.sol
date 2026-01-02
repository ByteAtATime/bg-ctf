// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Season2Challenge10} from "../../../src/season2/Season2Challenge10.sol";

// Step 1: Create a proxy contract to call the challenge
contract ProxyCaller {
    function callMint(Season2Challenge10 challenge) external {
        challenge.mintFlag();
    }
}

contract Challenge10Test is BaseTest {
    Season2Challenge10 challenge10;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge10 = new Season2Challenge10(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge10));
        vm.stopPrank();
    }

    function test_challenge10() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 2: Calculate target requirements
        // Req 1: Last hex char of Proxy must match last hex char of Player
        uint8 targetLast = uint8(abi.encodePacked(PLAYER)[19]) & 0xF;
        
        // Req 2: First hex char of Proxy must match first hex char of Challenge Contract
        uint8 targetFirst = uint8(abi.encodePacked(address(challenge10))[0]) & 0xF0;

        // Step 3: Grind salt to find a matching address via CREATE2
        bytes memory bytecode = type(ProxyCaller).creationCode;
        bytes32 bytecodeHash = keccak256(bytecode);
        uint256 salt = 0;
        address proxyAddress;

        while(true) {
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    address(this), // The test contract is the deployer
                    salt,
                    bytecodeHash
                )
            );
            proxyAddress = address(uint160(uint256(hash)));

            uint8 proxyLast = uint8(abi.encodePacked(proxyAddress)[19]) & 0xF;
            uint8 proxyFirst = uint8(abi.encodePacked(proxyAddress)[0]) & 0xF0;

            if (proxyLast == targetLast && proxyFirst == targetFirst) {
                break;
            }
            salt++;
        }

        // Step 4: Deploy and execute
        ProxyCaller proxy;
        assembly {
            proxy := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        
        require(address(proxy) == proxyAddress, "Address mismatch");
        proxy.callMint(challenge10);

        // DONE: You should have obtained the flag for challenge #10
        assertTrue(nftFlags.hasMinted(PLAYER, 10));
    }
}