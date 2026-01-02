# Challenge 8: Locked

In this challenge, you need to unlock a flag protected by four (!!) distinct locks involving storage privacy, contract balances, and controlled receipt of Ether.

## Contract Overview
The `mintFlag` function is protected by four modifiers:
1. `lock1`: Requires a password that matches a masked private storage variable.
2. `lock2`: Requires `msg.sender` to have a balance of at least 2 wei.
3. `lock3`: Requires a `send(1)` to `msg.sender` to **fail**.
4. `lock4`: Requires a `send(2)` to `msg.sender` to **succeed**.
- Additionally, you must send exactly 2 wei in the transaction.

## Hints
<details>
<summary>Hint 1</summary>
The `password` is `private`... or is it? This should remind you of [S1C9: Password Protected](../../season1/challenge9).
</details>

<details>
<summary>Hint 2</summary>
<code>lock3</code> and <code>lock4</code> depend on how your contract responds to receiving Ether. Remember that <code>send</code> only provides a fixed amount of gas (2,300 gas) to the recipient.
</details>

<details>
<summary>Hint 3</summary>
How can you make a <code>send</code> call fail? A contract can refuse to accept Ether by reverting in its <code>receive()</code> function.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **The Password**:
   Because `private` variables are not actually private, you can use tools to read storage slots 1 (`password`) and 2 (`count`). Apply the same bitwise mask used in the contract logic to get the correct input.

2. **The Solution Contract**:
   You must use a contract to solve this because you need to programmatically control when Ether transfers fail or succeed.
   ```solidity
   receive() external payable {
       if (msg.value == 1) revert(); // Makes lock3 pass (send(1) fails)
       if (msg.value == 2) {}       // Makes lock4 pass (send(2) succeeds)
   }
   ```

3. **Execution**:
   - Ensure your solution contract has a balance of at least 2 wei (for `lock2`).
   - Call `mintFlag` from your contract, passing exactly 2 wei and the calculated password.

Why this works:
- You bypassed "private" storage by reading the state directly.
- You used a smart contract to programmatically refuse a specific Ether transfer while accepting another, satisfying the specific requirements of the modifiers.
</details>

## Why This Matters
This challenge covers several critical security concepts:

1.  **On-chain Privacy**: As seen in [S1C9](../../season1/challenge9), nothing is private on Ethereum. Tools like `eth_getStorageAt` make it easy to inspect any contract's internal state.
2.  **Unexpected Reverts (DoS)**: `lock3` demonstrates how a contract can intentionally (or unintentionally) break another contract's logic by refusing to receive Ether. If a protocol requires sending Ether to a user to proceed, a user with a malicious contract can freeze the protocol. This is a common **Denial of Service (DoS)** vector.
3.  **Gas Limitations**: `send` and `transfer` only provide 2,300 gas. While they were originally intended to prevent reentrancy, they can cause transfers to fail if the recipient's `receive` function is too complex. Modern security best practices recommend using `call` instead (in fact, Solidity gives you a warning!), along with explicit reentrancy guards.