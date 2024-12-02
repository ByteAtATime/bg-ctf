# Challenge 12: The Block Header Oracle

In this challenge, you need to understand the complex inner workings of blocks to form some data with the same hash as a block.

## Contract Overview
The contract has two main functions:
- `preMintFlag()`: Registers your intent to mint and stores the current block number
- `mintFlag(bytes memory rlpBytes)`: Verifies that `keccak256(rlpBytes)` is the same as a block hash before minting the flag

## Hints
<details>
<summary>Hint 1</summary>
<code>mintFlag(bytes memory rlpBytes)</code> requires <code>keccak256(rlpBytes)</code> to be the same as <code>blockhash(registeredBlock)</code>. It's virtually impossible to find data that hashes to the same value. How else can you get some data that has the same hash?
</details>

<details>
<summary>Hint 2</summary>
Under the hood, <code>blockhash()</code> has a <code>keccak256()</code> operation. If we figure out the parameters to this hash, we can pass that into the <code>mintFlag()</code> function!
</details>

<details>
<summary>Hint 3</summary>
A block hash is the Keccak-256 hash of the block header encoded in RLP. Note that this is Optimism, so the block header will be different!

Specifically, here is the structure of the Optimism block header:

```
[
    parentBlockHash,
    sha3Uncles,
    miner,
    stateRoot,
    transactionsRoot,
    receiptsRoot,
    logsBloom,
    number,
    gasLimit,
    gasUsed,
    timestamp,
    extraData,
    mixHash,
    nonce, // <- after PoW, 8 bytes of zeros
    baseFeePerGas,
    withdrawalsRoot,
    blobGasUsed,
    excessBlobGas,
    parentBeaconBlockRoot
]
```
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. First, register for minting:
<pre><code>challenge12.preMintFlag();
uint256 targetBlock = block.number + challenge12.futureBlocks();</code></pre>

2. Get the block data for <code>targetBlock</code>. This can be obtained by an <code>eth_getBlockByNumber</code> call to an RPC.

3. After converting to a list (see hint #3), RLP encode it.

4. Submit the proof:
<pre><code>challenge12.mintFlag(rlpEncoded);</code></pre>

The contract will:
- Verify the block number matches
- Check that the RLP-encoded header matches the block hash
- Mint your flag if everything is correct

Congratulations! You've mastered block header verification and RLP encoding! 🎉
</details>
