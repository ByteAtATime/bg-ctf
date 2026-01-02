# Challenge 7: Calldata FTW

In this challenge, you need to manipulate the low-level structure of Ethereum transaction calldata to bypass a restrictive modifier.

## Contract Overview
The contract has a proxy-like function `mint(bytes _data)` that calls itself.
- `onlyChallenge7`: Ensures the caller is the contract itself.
- `onlyMintFlag`: Uses assembly to check if the transaction calldata at index 68 matches the `mintFlag` selector.
- You must call `allowMinter()` (to become authorized) and then `mintFlag()` (to get the NFT).

## Hints
<details>
<summary>Hint 1</summary>
The <code>mint(bytes)</code> function is the only way to trigger other functions because of the <code>onlyChallenge7</code> modifier.
</details>

<details>
<summary>Hint 2</summary>
Solidity encodes dynamic types (like <code>bytes</code>) using an offset. In a standard call to <code>mint(bytes)</code>:
- Bytes 0-3: Function Selector
- Bytes 4-35: Offset to the start of data (usually 32 or 0x20)
- Bytes 36-67: Length of the data
- Byte 68+: The actual content
</details>

<details>
<summary>Hint 3</summary>
If you use a standard call, byte 68 will always be the start of your <code>_data</code>. But the modifier requires byte 68 to be <code>mintFlagSelector</code>. If you want to call <code>allowMinter</code>, you must "misalign" the calldata so that <code>mintFlagSelector</code> sits at index 68, but the <code>_data</code> pointer points somewhere else.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **Crafting the Overlap**:
   We need to manually build the calldata. We'll tell Solidity that the `_data` parameter starts at byte 100. This leaves index 68 free for us to put the "magic" selector required by the modifier.

   Transaction Structure:
   - `0x00`: `mint(bytes)` selector
   - `0x04`: `100` (The offset where our `bytes` data starts)
   - `0x24`: `0` (Padding)
   - `0x44` (Index 68): `mintFlagSelector` (To pass the modifier)
   - ... padding ...
   - `0x64` (Index 100): Length of `_data`
   - `0x84`: The selector for the function we *actually* want to call (`allowMinter` or `mintFlag`).

2. **Execute steps**:
   - Send the custom payload to call `allowMinter()`.
   - Send the custom payload to call `mintFlag()`.

Why this works:
- The modifier `onlyMintFlag` looks at a fixed physical location in the transaction calldata (index 68).
- The Solidity compiler looks at the offset (index 4) to find the `_data` variable.
- By providing a non-standard offset, we satisfy both.
</details>

## Why This Matters
This challenge demonstrates **Function Selector Clashing** and the risks of relying on `msg.data` offsets for security checks. 

1.  **Proxy Vulnerabilities**: Many proxy patterns rely on parsing calldata. If the logic for parsing parameters is inconsistent with the logic used for security checks, attackers can "hide" malicious parameters or spoof authorized ones.
2.  **Cross-Function Reentrancy**: While not directly shown here, manipulating call context is a common theme in complex DeFi exploits where one function's parameters are misinterpreted by another during a `delegatecall` or `call` sequence.