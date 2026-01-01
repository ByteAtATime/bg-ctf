# Challenge 1: The Greeting

In this challenge, you need to register a team and get your first flag NFT! The contract allows teams to register with a name and team size.

## Contract Overview
The contract has a simple registration function that:
- Takes a team name and size as input
- Stores team information in a mapping
- Mints an NFT flag to the registered team

## Hints
<details>
<summary>Hint 1</summary>
Look at the requirements in the <code>registerTeam</code> function. What are the valid inputs?
</details>

<details>
<summary>Hint 2</summary>
The team size must be between 1 and 4 members.
</details>

<details>
<summary>Hint 3</summary>
The team name just needs to be non-empty.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

This is a straightforward challenge! To solve it:

1. Call the `registerTeam` function with:
   - Any non-empty string as the team name
   - A team size between 1 and 4

Example solution:
```solidity
challenge.registerTeam("My Team", 2);
```

That's it! The contract will store your team information and mint the flag NFT to your address.

Why this works:
- The name is non-empty, satisfying the first require check
- The team size (2) is between 1 and 4, satisfying the second require check
- The function will automatically mint the flag NFT to your address

Congratulations on getting your first flag! 🎉
</details>

Remember: Sometimes the simplest solution is the correct one. Don't overthink it!