# Challenge 2: Show me your key

In this challenge, you need to provide the correct key to unlock the flag.

## Contract Overview
The contract has a `mintFlag` function that:
- Accepts a `bytes32` key as an argument
- Calculates a key
- Compares your input with the target key
- Mints the flag if they match

## Hints
<details>
<summary>Hint 1</summary>
The key is calculated as <code>keccak256(abi.encodePacked(msg.sender, address(this)))</code>.
</details>

<details>
<summary>Hint 2</summary>
<code>msg.sender</code> is your address (the caller), and <code>address(this)</code> is the challenge contract's address.
</details>

<details>
<summary>Hint 3</summary>
Since all the data required to build the key is public, you can calculate it yourself before calling the function.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

To solve this challenge, you simply need to replicate the hashing logic locally and pass the result to the contract.

1. Calculate the key:
```solidity
bytes32 key = keccak256(abi.encodePacked(yourAddress, challengeAddress));
```

2. Call the function with the generated key:
```solidity
challenge2.mintFlag(key);
```

Why this works:
- The "key" is just a hash of public information (`msg.sender` and `address(this)`)
- You can perfectly predict what the contract expects and provide it

Congratulations! You've learned that hashing public data doesn't make it secret! 🎉
</details>

Remember: Everything on the blockchain is public. Deriving a "secret" key from public parameters like addresses makes it trivial to reverse-engineer or predict.

## Why This Matters
Developers sometimes mistake hashing for encryption or secrecy.

1. **Commit-Reveal Schemes**: Hashing is useful when you want to prove you know a value without revealing it yet (commit), but this requires the original value (pre-image) to be secret. Here, the pre-image is public.
2. **Authorization**: Relying on "keys" generated from public transaction context for authorization is insecure, as anyone can generate the valid key for their own transaction.
