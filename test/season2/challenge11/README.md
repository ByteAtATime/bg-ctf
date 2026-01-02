# Challenge 11: Give me the block!

This challenge builds upon [S1C12](../../season1/challenge12) but introduces a probabilistic element derived from the block's `mixHash`.

## Contract Overview
- `preMintFlag()`: Records the current block number and increments a counter for the sender.
- `mintFlag(bytes rlpBytes)`:
    - Validates the RLP-encoded block header against the block hash.
    - Extracts `mixHash` from the header (index 13).
    - Calculates a random number: `random = hash(mixHash, address, sender) % 10`.
    - Requires `random < counts[msg.sender]`.

## Hints
<details>
<summary>Hint 1</summary>
The `random` variable is calculated using `mixHash`, which comes from a future block. You cannot predict this value when you call `preMintFlag`.
</details>

<details>
<summary>Hint 2</summary>
The random value is modulo 10, meaning it will always be between 0 and 9.
</details>

<details>
<summary>Hint 3</summary>
The requirement is `random < counts[msg.sender]`. Can you increase `counts` enough so that this condition is *always* true, regardless of the random value?
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **Guarantee the Win**:
   The check `random < count` compares a number between 0-9 against your pre-mint count. If you call `preMintFlag()` 10 times, your count will be 10. Since `9 < 10` is always true, you eliminate the luck factor entirely.

2. **Wait and Encode**:
   Wait for the target block to be mined. Fetch the block header data (using RPC `eth_getBlockByNumber`), construct the list of fields (ParentHash, Sha3Uncles, Miner, etc.), and RLP encode it.

3. **Submit**:
   Call `mintFlag` with the encoded header.

Why this works:
- By incrementing the counter to the maximum possible value of the random generator (10), you brute-force the probability to 100%.
- The RLP encoding proves the block data is correct.
</details>

## Why This Matters
This challenge teaches two concepts:
1.  **Randomness on Blockchain**: Relying on block attributes like `mixHash` or `difficulty` for randomness is often insecure for two reasons: miners/validators can manipulate them (to an extent), and in this specific case, the "randomness" can be overwhelmed by game mechanics (the counter).
2.  **RLP (Recursive Length Prefix)**: This is the primary serialization format used in Ethereum's execution layer. Understanding it is key to working with low-level proofs and cross-chain bridges.