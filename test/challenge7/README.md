# Challenge 8: Delegate

In this challenge, you need to become the owner of the contract through a delegatecall vulnerability to mint your flag.

## Contract Overview
The setup involves two contracts:
1. `Challenge7` - The main contract with:
   - An owner variable
   - A delegate contract reference
   - A fallback function that delegatecalls to the delegate
2. `Challenge7Delegate` - A contract with:
   - Its own owner variable
   - A `claimOwnership` function

## Hints
<details>
<summary>Hint 1</summary>
Notice how both contracts have an <code>owner</code> variable in the same slot position
</details>

<details>
<summary>Hint 2</summary>
<code>delegatecall</code> executes code in the context of the calling contract, using its storage
</details>

<details>
<summary>Hint 3</summary>
The fallback function will delegatecall any function call it doesn't recognize to the delegate contract
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. Notice that when we call an unknown function, it gets forwarded via delegatecall to the delegate contract

2. Call <code>claimOwnership()</code> on the main contract:
<code>
address(challenge7).call(abi.encodeWithSignature("claimOwnership()"));
</code>

3. This works because:
   - The call gets forwarded via delegatecall
   - <code>claimOwnership()</code> sets owner to msg.sender
   - Due to delegatecall, it modifies the main contract's storage
   - Both contracts have 'owner' in the same storage slot

4. Now we can call <code>mintFlag()</code>

Congratulations! You've exploited a delegatecall vulnerability! 🎉
</details>

Remember: `delegatecall` is a powerful but dangerous feature. Always ensure storage layouts match and consider the security implications of executing external code in your contract's context!

## Why This Matters
Delegatecall vulnerabilities have led to some of the most significant hacks:

1. The Parity Multisig Wallet hack (2017, $30M lost) - Delegatecall allowed attackers to take ownership
2. The Punk Protocol hack (2021, $8.9M lost) - Very similar to Parity Multisig hack
3. The Curio hack (2024) - Delegatecall exploitation led to malicious minting of tokens

Common issues arise from:
- Storage layout mismatches
- Unexpected state modifications
- Confusion about execution context
