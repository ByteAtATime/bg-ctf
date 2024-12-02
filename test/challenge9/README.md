# Challenge 9: Password protected
In this challenge, you need to figure out a password that's stored "privately" in the contract, with an additional twist of bit manipulation!

## Contract Overview
The contract has:
- A "private" password
- A "private" count
- A `mintFlag` function that requires a partially masked version of the password

## Hints
<details>
<summary>Hint 1</summary>
In Ethereum, marking variables as "private" only prevents other contracts from reading them directly
</details>

<details>
<summary>Hint 2</summary>
All blockchain data is public - you can read any storage slot if you know where to look
</details>

<details>
<summary>Hint 3</summary>
Storage slots are assigned sequentially for state variables:
<ul>
    <li>slot 0: nftContract</li>
    <li>slot 1: password</li>
    <li>slot 2: count</li>
</ul>
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. First, read the "private" storage slots:
<pre><code>bytes32 password = await provider.getStorageAt(contractAddress, 1);
bytes32 count = await provider.getStorageAt(contractAddress, 2);</code></pre>

2. Calculate the mask and new password:
<pre><code>bytes32 mask = ~(bytes32(uint256(0xFF) << ((31 - (uint256(count) % 32)) * 8)));
bytes32 newPassword = password & mask;</code></pre>

3. Call mintFlag with the calculated password:
<pre><code>challenge9.mintFlag(newPassword);</code></pre>

Congratulations! You've learned that "private" doesn't mean "secret" in blockchain! 🎉
</details>

Remember: Never store sensitive information directly in blockchain storage, even if marked as private. Use proper cryptographic techniques if you need to maintain secrets!

## Why This Matters
I couldn't find any specific examples of this vulnerability in the wild, but it's still a good lesson in blockchain privacy.

This demonstrates:
- Nothing in smart contracts is truly private
- The difference between "private" and "secret"
- The importance of proper cryptographic techniques for actual privacy
