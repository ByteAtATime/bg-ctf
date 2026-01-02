# Challenge 12: Conquer the game

This is the final boss of Season 2. You must navigate a complex RPG-style system of contracts to ~~assert your dominance~~ win the game.

## Contract Overview
The challenge involves interacting with several helper contracts:
- `HeroNFT`: An ERC721 token you can mint with a URI.
- `GoldToken`: An ERC20 token with restricted `transfer` logic.
- `Inventory`: Owned by the challenge, stores a value derived from your HeroNFT.
- `Quest`, `Dungeon`, `Victory`: Contracts tracking game state.

The `mintFlag` function enforces several conditions:
1.  **Winner**: You must be marked as a winner in the `Victory` contract.
2.  **Rich**: An address calculated as `~tx.origin` must have > 1 ether of Gold.
3.  **Balance Puzzle**: Your Gold balance must equal `hash % 100 ether`, where `hash` is derived from the previous block hash and your inventory value.
4.  **Dungeon Position**: Your Gold balance must also match your calculated dungeon position.
5.  **Enemy Balance**: Your balance must equal the balance of `~tx.origin`.

## Hints
<details>
<summary>Hint 1</summary>
The `GoldToken` overrides the `transfer` function to add restrictions, but it's forgetting something... what other related function can you call instead?
</details>

<details>
<summary>Hint 2</summary>
The `Victory` and `Dungeon` contracts have public functions that allow you to set your status arbitrarily.
</details>

<details>
<summary>Hint 3</summary>
The "hash" calculation depends on `blockhash(block.number - 1)`. Within a single transaction, this value is constant and predictable. You can calculate exactly how much Gold you need to have.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1.  **Become a Winner**: Call `dungeon.setPosition(...)` (non-zero) and `victory.free(true)`. This satisfies the `winner` modifier.

2.  **Mint Hero & Set Inventory**: Mint a HeroNFT with a URI of "5". The challenge parses this string: '5' (0x35) - 0x35 = 0. This sets your inventory value to 0, simplifying the hash calculation.

3.  **Calculate Target Balance**: Inside your solution contract, calculate the expected hash using `blockhash(block.number - 1)`, the challenge address, and the inventory value (0). The target balance is `hash % 100 ether`.

4.  **Manipulate Balances**:
    - The `GoldToken` prevents standard transfers if you don't have enough HeroNFTs/Dungeon progress. However, `transferFrom` uses the base ERC20 implementation, bypassing these checks.
    - Approve your solution contract to spend its own tokens.
    - Use `transferFrom` to send `targetBalance` to the enemy address (`~tx.origin`).
    - Burn tokens until your own balance is also exactly `targetBalance`.

5.  **Align Dungeon**: Set `Quest` to 1 and `Dungeon` position to `targetBalance`. This satisfies `balance == quest * dungeon`.

6.  **Execute**: Set allowance to match inventory (0) and call `mintFlag`.

Why this works:
- **Bypassing Logic**: `transferFrom` often skips custom logic implemented in `transfer` unless specifically overridden.
- **Predictable Randomness**: "Random" values based on block hashes are predictable within the transaction that executes them.
</details>

## Why This Matters
1.  **Incomplete Overrides**: When inheriting from standard libraries (like OpenZeppelin), overriding `transfer` does not automatically secure `transferFrom`. You must override both (or `_update` in newer versions) to ensure logic applies to all token movements.
2.  **Flash Calculations**: Complex mathematical constraints based on chain state can often be solved "just-in-time" by a smart contract in the same transaction, rendering them ineffective as security puzzles or randomness sources.