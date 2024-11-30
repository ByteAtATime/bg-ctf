// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract Challenge8Test is BaseTest {
    address challenge8;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        bytes memory bytecodeBase =
            hex"608060405234801561001057600080fd5b5060405161022c38038061022c83398101604081905261002f91610054565b600080546001600160a01b0319166001600160a01b0392909216919091179055610084565b60006020828403121561006657600080fd5b81516001600160a01b038116811461007d57600080fd5b9392505050565b610199806100936000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80638fd628f01461003b578063d56d229d14610050575b600080fd5b61004e610049366004610133565b61007f565b005b600054610063906001600160a01b031681565b6040516001600160a01b03909116815260200160405180910390f35b6001600160a01b03811633146100cc5760405162461bcd60e51b815260206004820152600e60248201526d24b73b30b634b21036b4b73a32b960911b604482015260640160405180910390fd5b6000546040516340c10f1960e01b8152336004820152600860248201526001600160a01b03909116906340c10f1990604401600060405180830381600087803b15801561011857600080fd5b505af115801561012c573d6000803e3d6000fd5b5050505050565b60006020828403121561014557600080fd5b81356001600160a01b038116811461015c57600080fd5b939250505056fea26469706673582212202574d345d5aad3eba6e8e8374fb2634c736f99936431d51dd35a55f1503ef1c764736f6c63430008140033";

        bytes memory bytecodeWithParameters =
            abi.encodePacked(bytecodeBase, abi.encodePacked(uint256(uint160(address(nftFlags)))));

        bytes memory challenge8Code = bytecodeWithParameters;

        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(challenge8Code, 0x20), mload(challenge8Code))
        }

        challenge8 = deployedAddress;
        nftFlags.addAllowedMinter(deployedAddress);

        vm.stopPrank();
    }

    function test_challenge8() public {
        vm.startPrank(PLAYER, PLAYER);

        (bool success,) = challenge8.call(abi.encodeWithSelector(0x8fd628f0, PLAYER));
        assertTrue(success);

        assertTrue(nftFlags.hasMinted(PLAYER, 8));
    }
}
