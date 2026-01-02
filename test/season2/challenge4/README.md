# Challenge 4: Pay me!

In this challenge, you need to pay the contract 1 gwei, but the `mintFlag` function doesn't accept ETH directly.

## Contract Overview
The contract has two main entry points:
1. `mintFlag()`: This function resets a payment flag, calls the sender, checks if payment was received, and then mints the flag.
2. `receive()`: This function accepts ETH. If the amount is exactly 1 gwei, it marks the payment flag as true.

## Hints
<details>
<summary>Hint 1</summary>
The <code>mintFlag</code> function makes a low-level call to <code>msg.sender</code>: <code>msg.sender.call("")</code>. What side effect does this have?
</details>

<details>
<summary>Hint 2</summary>
You need <code>_paid</code> to be true *after* the callback returns, but it is set to false right before the callback.
</details>

<details>
<summary>Hint 3</summary>
Your contract needs to trigger the challenge's <code>receive</code> function while inside the callback initiated by <code>mintFlag</code>.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. Create a contract that can receive the callback and pay the challenge:
```solidity
contract Solution {
    Season2Challenge4 challenge;

    constructor(Season2Challenge4 _challenge) {
        challenge = _challenge;
    }

    function solve() external {
        challenge.mintFlag();
    }

    // Handle the callback
    receive() external payable {
        if (msg.sender == address(challenge)) {
            // Send the required payment back to the challenge
            (bool success, ) = address(challenge).call{value: 1 gwei}("");
            require(success, "Payment failed");
        }
    }
}
```

2. Deploy the contract and fund it with at least 1 gwei.
3. Call `solve()`.

Why this works:
1. `mintFlag` sets `_paid = false`.
2. `mintFlag` calls your contract (`msg.sender.call("")`).
3. Your contract's `receive` function triggers.
4. Inside `receive`, you send 1 gwei back to the challenge.
5. The challenge's `receive` function sets `_paid = true`.
6. Your function finishes, control returns to `mintFlag`.
7. `mintFlag` checks `_paid` (which is now true) and mints the flag.
</details>

## Why This Matters
This pattern demonstrates **Control Flow Handover**. When a contract calls an external address (especially using `call`), it pauses its own execution and hands control over to the called address.

While this challenge uses it "safely" (by checking a condition after the call), this mechanism is the root cause of **Reentrancy Attacks**. In a reentrancy attack, the called contract would call *back* into the original function (or another function sharing state) before the original state updates were finalized.

This challenge is conceptually the inverse of [S1C5: Give Me My Points!](../../season1/challenge5). In S1C5, you used the callback to re-enter a function to exploit state that hadn't updated yet. Here, you use the callback to update state that the caller is waiting for.