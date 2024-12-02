# Challenge 11: Who can call me?

In this challenge, you need to find a contract address whose last byte, when masked, matches your address's last byte. It combines both proxy calling and bit manipulation!

## Contract Overview
The contract requires:
- Calling through another contract (`msg.sender != tx.origin`)
- The last bytes of both addresses, when masked with `0x15`, must match
- Only then will it mint the flag

## Hints
<details>
<summary>Hint 1</summary>
The mask <code>0x15</code> in binary is <code>00010101</code> - it only looks at specific bits
</details>

<details>
<summary>Hint 2</summary>
Contract addresses are deterministic - they depend on the creator's address and nonce
</details>

<details>
<summary>Hint 3</summary>
You can keep creating new contracts until you find one with a matching address pattern
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. Create a contract that will call the challenge:
<pre><code>contract Caller {
    function call(Challenge11 challenge) public {
        challenge.mintFlag();
    }
}</code></pre>

2. Keep deploying the contract until you find a matching address:
<pre><code>while (true) {
    Caller caller = new Caller();
    
    uint8 senderLast = uint8(abi.encodePacked(tx.origin)[19]);
    uint8 callerLast = uint8(abi.encodePacked(address(caller))[19]);
    
    if ((senderLast & 0x15) == (callerLast & 0x15)) {
        caller.call(challenge);
        break;
    }
}</code></pre>

The matching occurs when:
- Last bytes AND <code>0x15</code> (00010101)
- Only bits 0, 2, and 4 matter
- Other bits are masked out

Congratulations! You've mastered both proxy calling and bit manipulation! 🎉
</details>

Remember: Bit manipulation is a powerful tool in smart contracts, but it requires careful consideration of all possible patterns and edge cases!
