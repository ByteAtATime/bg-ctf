# Challenge 3: Let me in!

In this challenge, you need to call the contract... but `tx.origin` can't be `msg.sender`???

## Contract Overview
The contract has a `mintFlag` function that:
- Verifies that `msg.sender` (the caller) is not `tx.origin` (the signer of the transaction).
- Calls `accessKey()` on `msg.sender`.
- Checks if the returned string matches "LET_ME_IN".
- Mints the flag to `tx.origin`.

## Hints
<details>
<summary>Hint 1</summary>
The condition <code>msg.sender != tx.origin</code> means you cannot call the function directly from your wallet. You must use a smart contract. This challenge is quite similar to [S1C2: Just Call Me Maybe](../../season1/challenge2).
</details>

<details>
<summary>Hint 2</summary>
The contract casts <code>msg.sender</code> to <code>ISeason2Challenge3Solution</code> and calls <code>accessKey()</code>. Your intermediary contract must implement this function.
</details>

<details>
<summary>Hint 3</summary>
The expected return value is the string "LET_ME_IN".
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. Create a contract that implements the `accessKey` function and a way to trigger the mint:
```solidity
contract Solution {
    function accessKey() external pure returns (string memory) {
        return "LET_ME_IN";
    }

    function solve(Season2Challenge3 challenge) external {
        challenge.mintFlag();
    }
}
```

2. Deploy this contract.

3. Call the `solve` function on your deployed contract, passing the challenge contract address.

Why this works:
- When you call `Solution.solve()`, `tx.origin` is your wallet, but inside `mintFlag`, `msg.sender` is the `Solution` contract address. This satisfies the `msg.sender != tx.origin` check.
- The `Solution` contract implements `accessKey()` which returns the correct string required by the challenge.

Congratulations! You've successfully interacted with a contract interface! 🎉
</details>

## Why This Matters

_(This section is copied from [S1C2: Just Call Me Maybe](../../season1/challenge2))_

Understanding the difference between `msg.sender` and `tx.origin` is crucial for smart contract security:

1. Multiple phishing contracts have exploited users by relying on `tx.origin` for authentication
2. OpenZeppelin explicitly warns against using `tx.origin` for authorization in their security guidelines

Smart contracts using `tx.origin` for authentication are vulnerable to phishing attacks where a malicious contract forwards calls to the target contract while maintaining the victim's `tx.origin`.
