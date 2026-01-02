# Challenge 10: Who can call me?

In this challenge, you need to deploy a contract to a specific address that satisfies two different masking conditions relative to your address and the challenge contract's address.

## Contract Overview
The `mintFlag` function enforces three checks:
1. `msg.sender != tx.origin`: You must call it from a smart contract.
2. `(msg.sender_last_byte & 0xF) == (tx.origin_last_byte & 0xF)`: The last hex character of your contract's address must match yours.
3. `(msg.sender_first_byte & 0xF0) == (contract_first_byte & 0xF0)`: The first hex character of your contract's address must match the challenge contract's.

## Hints
<details>
<summary>Hint 1</summary>
There's a certain operation to calculate the resulting address when a contract is deployed by another contract.
</details>

<details>
<summary>Hint 2</summary>
Bitwise AND (`&`) with `0xF` extracts the last hexadecimal digit. Bitwise AND with `0xF0` extracts the first hexadecimal digit of a byte.
</details>

<details>
<summary>Hint 3</summary>
This is virtually identical to [S1C11: Who can call me?](../../season1/challenge11), just with some different requirements.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **Define the Proxy**:
   Create a simple contract that calls `mintFlag()`:
   ```solidity
   contract Proxy {
       function run(Season2Challenge10 c) external { c.mintFlag(); }
   }
   ```

2. **Grind the Salt**:
   Write a script to loop through `salt` values. For each salt, calculate the resulting address using the `CREATE2` formula:
   `keccak256(0xff ++ deployerAddr ++ salt ++ keccak256(bytecode))`

   Check if the resulting address satisfies both bitwise conditions.

3. **Deploy and Execute**:
   Once a valid salt is found, use `create2` assembly to deploy the proxy and call the challenge.

   ```solidity
   // (Simplified logic)
   assembly {
       proxy := create2(0, add(bytecode, 0x20), mload(bytecode), validSalt)
   }
   Proxy(proxy).run(challenge);
   ```

Why this works:
- `CREATE2` allows us to predict the deployment address before deployment.
- By trying different `salt` values, we can "mine" a vanity address that fits the specific constraints imposed by the challenge.
</details>

## Why This Matters
Address determinism and vanity addresses are used in various protocols. For example, Uniswap V3 pool addresses are deterministic based on the tokens and fee tier.

However, relying on address parameters for security (like checking if an address starts with specific bytes) is insecure because, as shown here, attackers can easily generate addresses to bypass these checks.