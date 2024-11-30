# Challenge 3: The Constructor Call

In this challenge, you need to call the contract through another contract, but with a twist - the calling contract must have no code at the time of the call!

## Contract Overview
The contract has a `mintFlag()` function that:
- Checks if the caller is different from the transaction originator
- Verifies that the caller's code size is zero
- Mints an NFT flag to the transaction originator if successful

## Hints
<details>
<summary>Hint 1</summary>
Remember the contract lifecycle - when exactly does a contract get its code?
</details>

<details>
<summary>Hint 2</summary>
During a contract's constructor execution, its code size is still zero!
</details>

<details>
<summary>Hint 3</summary>
You'll need to make the call to <code>mintFlag()</code> from within a constructor.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

Create a contract that calls <code>mintFlag()</code> in its constructor:

<code>
contract CallHelper {
    constructor(Challenge3 challenge3) {
        challenge3.mintFlag();
    }
}
</code>

Then simply deploy this contract with the Challenge3 address as a parameter.

Why this works:
- During constructor execution, the contract's code hasn't been deployed yet
- <code>extcodesize</code> returns 0 during this phase
- The call comes from a contract (satisfying <code>msg.sender != tx.origin</code>)
- The flag gets minted to your address (<code>tx.origin</code>)

Congratulations! You've learned about contract deployment mechanics and a common security pitfall! 🎉
</details>

Remember: Just because a contract appears to have no code doesn't mean it can't execute code! Always be careful when making assumptions about contract vs EOA interactions.

## Why This Matters
The `extcodesize` check has been historically used as a way to determine if an address belongs to a contract, but this assumption can be dangerous:

1. FoMo3D airdrop vulnerability (2018, $12M at risk) involved a contract that could be called by another contract to bypass the `extcodesize` check, airdropping tokens to the attacker
2. Several protocols have been vulnerable to attacks where malicious contracts performed actions during their construction phase

This demonstrates why using `extcodesize` alone is not a reliable method for determining if a caller is a contract or an EOA (Externally Owned Account).
