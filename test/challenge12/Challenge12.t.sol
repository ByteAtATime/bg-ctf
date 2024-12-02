// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {Challenge12} from "../../src/Challenge12.sol";
import {NFTFlags} from "../../src/NFTFlags.sol";

contract Challenge12Test is BaseTest {
    Challenge12 challenge12;

    struct BlockData {
        bytes32 parentBlockHash;
        bytes32 sha3Uncles;
        address miner;
        bytes32 stateRoot;
        bytes32 transactionsRoot;
        bytes32 receiptsRoot;
        bytes logsBloom;
        uint256 number;
        uint256 gasLimit;
        uint256 gasUsed;
        uint256 timestamp;
        bytes extraData;
        bytes32 mixHash;
        bytes8 nonce;
        uint256 baseFeePerGas;
        bytes32 withdrawalsRoot;
        uint256 blobGasUsed;
        uint256 excessBlobGas;
        bytes32 parentBeaconBlockRoot;
    }

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);
        challenge12 = new Challenge12(address(nftFlags));
        nftFlags.addAllowedMinter(address(challenge12));
        vm.stopPrank();
    }

    function test_challenge12() public {
        vm.startPrank(PLAYER, PLAYER);

        // Step 1: register for minting
        challenge12.preMintFlag();
        uint256 registeredBlockNumber = block.number + challenge12.futureBlocks();

        // Go to 3 blocks in the future
        vm.roll(block.number + 3);

        // Step 2: Get block data
        BlockData memory blockData = getBlockData(registeredBlockNumber);

        // Step 3: Encode block data with RLP
        bytes[21] memory header = [
            RLPEncoder.rlpEncodeBytes32(blockData.parentBlockHash),
            RLPEncoder.rlpEncodeBytes32(blockData.sha3Uncles),
            RLPEncoder.rlpEncodeAddress(blockData.miner),
            RLPEncoder.rlpEncodeBytes32(blockData.stateRoot),
            RLPEncoder.rlpEncodeBytes32(blockData.transactionsRoot),
            RLPEncoder.rlpEncodeBytes32(blockData.receiptsRoot),
            RLPEncoder.rlpEncodeBytes(blockData.logsBloom),
            RLPEncoder.blankPrefix(), // difficulty
            RLPEncoder.rlpEncodeUint(blockData.number),
            RLPEncoder.rlpEncodeUint(blockData.gasLimit),
            RLPEncoder.rlpEncodeUint(blockData.gasUsed),
            RLPEncoder.rlpEncodeUint(blockData.timestamp),
            RLPEncoder.rlpEncodeBytes(blockData.extraData),
            RLPEncoder.rlpEncodeBytes32(blockData.mixHash),
            RLPEncoder.noncePrefix(),
            abi.encodePacked(blockData.nonce),
            RLPEncoder.rlpEncodeUint(blockData.baseFeePerGas),
            RLPEncoder.rlpEncodeBytes32(blockData.withdrawalsRoot),
            RLPEncoder.rlpEncodeUint(blockData.blobGasUsed),
            RLPEncoder.rlpEncodeUint(blockData.excessBlobGas),
            RLPEncoder.rlpEncodeBytes32(blockData.parentBeaconBlockRoot)
        ];

        // Convert header to array and RLP encode
        bytes[] memory headerArray = new bytes[](21);
        for (uint256 i = 0; i < 21; i++) {
            headerArray[i] = header[i];
        }
        bytes memory rlpEncodedHeader = RLPEncoder.rlpEncodeList(headerArray);

        // Step 4: Mint flag
        challenge12.mintFlag(rlpEncodedHeader);

        assertTrue(nftFlags.hasMinted(PLAYER, 12));
    }

    // The following are all artifacts of my poor decision to do this purely in Solidity
    // It was definitely not intended for this purpose, so there is a lot of hacky code
    // If you are interested, read on; otherwise, ignore all of this

    function parseBlockData(string memory json) public pure returns (BlockData memory) {
        return BlockData(
            vm.parseJsonBytes32(json, ".result.parentHash"),
            vm.parseJsonBytes32(json, ".result.sha3Uncles"),
            vm.parseJsonAddress(json, ".result.miner"),
            vm.parseJsonBytes32(json, ".result.stateRoot"),
            vm.parseJsonBytes32(json, ".result.transactionsRoot"),
            vm.parseJsonBytes32(json, ".result.receiptsRoot"),
            vm.parseJsonBytes(json, ".result.logsBloom"),
            vm.parseJsonUint(json, ".result.number"),
            vm.parseJsonUint(json, ".result.gasLimit"),
            vm.parseJsonUint(json, ".result.gasUsed"),
            vm.parseJsonUint(json, ".result.timestamp"),
            vm.parseJsonBytes(json, ".result.extraData"),
            vm.parseJsonBytes32(json, ".result.mixHash"),
            0x0000000000000000, // nonce was only used on PoW (now it is 32 bits of 0s)
            vm.parseJsonUint(json, ".result.baseFeePerGas"),
            vm.parseJsonBytes32(json, ".result.withdrawalsRoot"),
            vm.parseJsonUint(json, ".result.blobGasUsed"),
            vm.parseJsonUint(json, ".result.excessBlobGas"),
            vm.parseJsonBytes32(json, ".result.parentBeaconBlockRoot")
        );
    }

    function getBlockData(uint256 blockNumber) public returns (BlockData memory) {
        string[] memory inputs = constructBlockDataCurl(blockNumber);

        string memory res = string(vm.ffi(inputs));

        return parseBlockData(res);
    }

    function constructBlockDataCurl(uint256 blockNumber) public pure returns (string[] memory) {
        string[] memory inputs = new string[](7);
        inputs[0] = "curl";
        inputs[1] = "-s";
        inputs[2] = "-X";
        inputs[3] = "POST";
        inputs[4] = "https://rpc.ankr.com/optimism";
        inputs[5] = "-d";
        inputs[6] = string.concat(
            '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["',
            RLPEncoder.uintToHexString(blockNumber),
            '",false],"id":1}'
        );

        return inputs;
    }
}

library RLPEncoder {
    function rlpEncodeUint(uint256 value) internal pure returns (bytes memory) {
        return rlpEncodeBytes(stripLeadingZeros(value));
    }

    function rlpEncodeBytes(bytes memory value) internal pure returns (bytes memory) {
        if (value.length == 0) {
            return abi.encodePacked(blankPrefix());
        }

        if (value.length <= 55) {
            uint8 prefix = 0x80 + uint8(value.length);
            return abi.encodePacked(prefix, value);
        }

        bytes memory length = stripLeadingZeros(value.length);
        uint8 lengthPrefix = 0xb7 + uint8(length.length);

        return abi.encodePacked(lengthPrefix, length, value);
    }

    function rlpEncodeList(bytes[] memory values) internal pure returns (bytes memory) {
        bytes memory rlpEncodedValues;
        for (uint256 i = 0; i < values.length; i++) {
            rlpEncodedValues = abi.encodePacked(rlpEncodedValues, values[i]);
        }

        if (rlpEncodedValues.length <= 55) {
            uint8 prefix = 0xc0 + uint8(rlpEncodedValues.length);
            return abi.encodePacked(prefix, rlpEncodedValues);
        }

        bytes memory length = stripLeadingZeros(rlpEncodedValues.length);
        uint8 lengthPrefix = 0xf7 + uint8(length.length);

        return abi.encodePacked(lengthPrefix, length, rlpEncodedValues);
    }

    function stripLeadingZeros(uint256 value) internal pure returns (bytes memory) {
        bytes memory packedValue = new bytes(0);
        while (value > 0) {
            packedValue = abi.encodePacked(uint8(value % 256), packedValue);
            value /= 256;
        }

        return packedValue;
    }

    function rlpEncodeBytes32(bytes32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(bytes32Prefix(), value);
    }

    function rlpEncodeAddress(address value) internal pure returns (bytes memory) {
        return abi.encodePacked(addressPrefix(), value);
    }

    function uintToHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x";
        }

        bytes memory buffer = new bytes(64);
        uint256 index = 64;
        while (value != 0) {
            index--;
            buffer[index] = bytes1(uint8(48 + uint256(value) % 16));
            if (uint8(buffer[index]) > 57) {
                buffer[index] = bytes1(uint8(uint8(buffer[index]) + 39));
            }
            value /= 16;
        }

        bytes memory bufWithoutLeadingZeros = new bytes(64 - index);
        for (uint256 i = 0; i < 64 - index; i++) {
            bufWithoutLeadingZeros[i] = buffer[index + i];
        }

        return string(abi.encodePacked("0x", bufWithoutLeadingZeros));
    }

    // Helper methods for generating RLP prefixes
    function bytes32Prefix() public pure returns (bytes memory) {
        return abi.encodePacked(uint8(0x80 + 32));
    }

    function addressPrefix() public pure returns (bytes memory) {
        return abi.encodePacked(uint8(0x80 + 20));
    }

    function blankPrefix() public pure returns (bytes memory) {
        return abi.encodePacked(uint8(0x80));
    }

    function noncePrefix() public pure returns (bytes memory) {
        return abi.encodePacked(uint8(0x80 + 8));
    }
}
