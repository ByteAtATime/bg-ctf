# Challenge 8: The Bytecode Mystery

In this challenge, you're presented with raw bytecode for a contract. You need to understand what it does and how to interact with it to get your flag!

## Contract Overview
The contract is provided as raw bytecode, making it harder to understand its functionality. However, we can deduce that:
- It's deployed with a parameter (an address)
- It has at least two functions
- It interacts with our NFT contract

## Hints
<details>
<summary>Hint 1</summary>
The bytecode includes function selectors. One important one is <code>0x8fd628f0</code>
</details>

<details>
<summary>Hint 2</summary>
When a contract's source code isn't available, you can use tools like Etherscan's bytecode decompiler or the Dedaub decompiler
</details>

<details>
<summary>Hint 3</summary>
The contract expects an address parameter and compares it with <code>msg.sender</code>
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. First, we can identify that the contract has two functions:
<pre><code>0x8fd628f0 - Main function that mints the flag
0xd56d229d - Getter for an address variable</code></pre>

2. The main function expects an address parameter and requires:
<pre><code>require(parameter == msg.sender, "Invalid sender");</code></pre>

3. Call the contract with your address:
<pre><code>(bool success, ) = challenge8.call(
    abi.encodeWithSelector(0x8fd628f0, yourAddress)
);</code></pre>

The contract will:
- Verify you're calling with your own address
- Mint the flag token to you

Congratulations! You've successfully analyzed and interacted with raw bytecode! 🎉
</details>

Remember: In production, always verify your contract source code. Unverified contracts are a red flag and require careful analysis before interaction!

## Why This Matters
Working with raw bytecode and contract verification is crucial in blockchain security:

1. Multiple "rugpulls" have hidden malicious logic in unverified contracts
2. The "Fake Token" scams often use bytecode that looks similar to legitimate tokens

This demonstrates:
- The importance of contract verification
- How to analyze raw bytecode
- How an unverified contract is not a good way to obfuscate logic
