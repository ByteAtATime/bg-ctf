# Challenge 4: The Known Private Key

In this challenge, you need to mint a flag using a signature from an authorized minter.

## Contract Overview
The contract includes:

- A list of authorized minters managed by the owner
- A mintFlag function that requires:
    - A valid minter address
    - A signature from that minter approving the mint for your address

## Hints
<details>
<summary>Hint 1</summary>
The authorized minter address (0xFABB0ac9d68B0B445fB7357272Ff202C5651694a) is a commonly used test address
</details>

<details>
<summary>Hint 2</summary>
Many development environments (Hardhat, Ganache) come with predefined accounts and their private keys
</details>

<details>
<summary>Hint 3</summary>
If you know the private key, you can generate valid signatures for any message!
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

The authorized minter is using a well-known Hardhat test account:
- Address: <code>0xFABB0ac9d68B0B445fB7357272Ff202C5651694a</code>
- Private Key: <code>0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1</code>

1. Construct the message:
<code>
bytes32 message = keccak256(abi.encode("BG CTF Challenge 4", your_address));
bytes32 hash = message.toEthSignedMessageHash();
</code>

2. Sign it with the known private key to get your signature

3. Call the contract:
<code>
challenge4.mintFlag(MINTER_ADDRESS, signature);
</code>

Congratulations! You've learned about the dangers of using known private keys! 🎉
</details>

Remember: In production, private keys should be secure, random, and never shared or reused from test environments!

## Why This Matters
Using known private keys in production is catastrophic:

1. The Harmony Horizon Bridge hack (2022, $100M lost) involved compromised private keys
2. Multiple projects have been drained after accidentally committing private keys to GitHub
3. The Slope wallet incident (2022) exposed thousands of private keys through logging

This challenge demonstrates why you should:
- Never use known test accounts in production
- Keep private keys secure and never reuse test keys
- Be wary of any system using well-known addresses
