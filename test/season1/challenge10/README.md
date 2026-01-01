# Challenge 10: Give 1 Get 1

In this challenge, you need to discover a hidden minting mechanism in the NFT contract itself! The key lies in the `onERC721Received` function.

## Contract Overview
The NFTFlags contract includes:
- Standard ERC721 functionality
- A special `onERC721Received` handler
- Requirements for specific token IDs and ownership

## Hints
<details>
<summary>Hint 1</summary>
Look carefully at the <code>onERC721Received</code> function. What does it check for?
</details>

<details>
<summary>Hint 2</summary>
You need two specific tokens: one from Challenge 1 and one from Challenge 9
</details>

<details>
<summary>Hint 3</summary>
The function expects the token IDs to be passed in a specific way through the <code>data</code> parameter during transfer
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. You need two tokens:
   - Token ID from Challenge 1 (registration)
   - Token ID from Challenge 9

2. Transfer token 1 to the contract with token 9's ID as data:
<code>
nftFlags.safeTransferFrom(
    yourAddress,
    address(nftFlags),
    token1Id,
    abi.encodePacked(token9Id)
);
</code>

The contract will:
- Verify you own both tokens
- Check that they're the correct challenge tokens
- Mint you the secret flag (10)
- Return your original token

Congratulations! You've discovered and exploited a hidden minting mechanism! 🎉
</details>

Remember: All contract code is public and can be analyzed. Hidden mechanics aren't truly hidden - they're just waiting to be discovered!

## Why This Matters
Hidden functionality in smart contracts has led to several security incidents:

1. Multiple "honeypot" contracts have used hidden mechanics to trap users
2. The "Rubixi" vulnerability where hidden admin functions were discovered and exploited

This demonstrates:
- The importance of thorough contract auditing
- How "hidden" mechanics can be discovered through code analysis
- The risks of complex token interaction patterns