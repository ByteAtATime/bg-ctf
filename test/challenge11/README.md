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
There is actually a way you can calculate the address at which a contract will be deployed... but it requires a different way to deploy the contract.
</details>

<details>
<summary>Hint 3</summary>
Have you tried using the <a href="https://book.getfoundry.sh/tutorials/create2-tutorial"><code>CREATE2</code></a> opcode?

The address it will deploy to is calculated as the last 20 bytes of:

```
keccak256(0xff ++ address ++ salt ++ keccak256(init_code))
```

Where:
- `0xff` is a constant **byte**
- `address` is the address of the contract deploying the new contract
- `salt` is a **uint256** that can be manipulated to get the desired address
- `init_code` is the bytecode of the contract being deployed
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

Instead of randomly creating contracts until we find one with a matching address, we can use CREATE2 to deterministically calculate and choose the address we want.

1. First, create the intermediary contract:
<pre><code>contract CallChallenge11 {
    function callChallenge11(Challenge11 challenge11) public {
        challenge11.mintFlag();
    }
}</code></pre>

2. Get the contract's creation code and its hash:
<pre><code>// Get the bytecode of our contract
bytes memory callerBytecode = type(CallChallenge11).creationCode;

// Calculate the hash of the bytecode
bytes32 bytecodeHash = keccak256(callerBytecode);</code></pre>

3. Calculate potential addresses until we find a match:
<pre><code>uint256 salt = 0;

while (true) {
    // Calculate the address where the contract would be deployed
    bytes32 deployedAddressBytes = keccak256(
        abi.encodePacked(
            bytes1(0xff),         // CREATE2 prefix
            PLAYER,               // deploying address
            salt,                 // current salt
            bytecodeHash         // bytecode hash
        )
    );
    address deployedAddress = address(uint160(uint256(deployedAddressBytes)));

    // Check if the last bytes match when masked
    uint8 senderLast = uint8(abi.encodePacked(deployedAddress)[19]);
    uint8 originLast = uint8(abi.encodePacked(PLAYER)[19]);

    if ((senderLast & 0x15) == (originLast & 0x15)) {
        break;
    }

    salt++;
}</code></pre>

4. Deploy the contract using the found salt:
<pre><code>address addr;
assembly {
    addr := create2(
        0,                                    // value to send
        add(callerBytecode, 0x20),           // actual bytecode
        mload(callerBytecode),               // length of bytecode
        salt                                 // our calculated salt
    )
}

// Verify the address matches our calculation
assert(addr == deployedAddress);</code></pre>

5. Finally, call the challenge through our deployed contract:
<pre><code>CallChallenge11(addr).callChallenge11(challenge11);</code></pre>

Congratulations! You've mastered CREATE2 and bit manipulation! 🎉
</details>

Remember: CREATE2 is a powerful tool for deterministic contract deployment, but always verify the deployed addresses match your calculations!
