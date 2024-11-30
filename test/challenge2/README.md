# Challenge 2: The Proxy Call

In this challenge, you need to call a function through another contract. The contract will only mint your flag if you call it indirectly!

## Contract Overview
The contract has a single function `justCallMe()` that:
- Checks if the caller is different from the transaction originator
- Mints an NFT flag to the transaction originator if successful

## Hints
<details>
<summary>Hint 1</summary>
Look at the difference between `msg.sender` and `tx.origin`. What do these mean in Solidity?
</details>

<details>
<summary>Hint 2</summary>
`msg.sender` is the immediate caller of a function, while `tx.origin` is the original address that started the transaction.
</details>

<details>
<summary>Hint 3</summary>
You'll need to create another contract that calls this one. When Contract A calls Contract B, `msg.sender` will be Contract A's address!
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

To solve this challenge, you need to create an intermediary contract:

```solidity
contract CallHelper {
    function callChallenge2(Challenge2 challenge2) public {
        challenge2.justCallMe();
    }
}
```

Then:
1. Deploy your CallHelper contract
2. Call `callChallenge2()` with the Challenge2 contract address

When you do this:
- `tx.origin` will be your address (the original caller)
- `msg.sender` will be the CallHelper contract's address
- The require check passes because `msg.sender != tx.origin`
- The flag gets minted to your address (`tx.origin`)

Congratulations! You've learned about contract interactions and the difference between `msg.sender` and `tx.origin`! 🎉
</details>

Remember: Understanding how contracts interact with each other is fundamental to Ethereum development. This pattern is commonly used in proxy contracts and other advanced patterns!

## Why This Matters
Understanding the difference between `msg.sender` and `tx.origin` is crucial for smart contract security:

1. Multiple phishing contracts have exploited users by relying on `tx.origin` for authentication
2. OpenZeppelin explicitly warns against using `tx.origin` for authorization in their security guidelines

Smart contracts using `tx.origin` for authentication are vulnerable to phishing attacks where a malicious contract forwards calls to the target contract while maintaining the victim's `tx.origin`.
