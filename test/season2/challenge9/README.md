# Challenge 9: The unverified

In this challenge, you are provided with a contract that has no verified source code. 

## Contract Overview
The contract is deployed using raw bytecode. By analyzing the bytecode and the deployment script, we can deduce:
- It is initialized with a specific address derived from a mnemonic.
- It verifies signatures.
- It contains error messages that reveal the expected message format.

## Hints
<details>
<summary>Hint 1</summary>
This is what the deployment script looks like:
<pre><code>const challenge9BytecodeBase = "...";
const nftFlagsAddress = await nftFlags.getAddress();
const challenge9Bytecode = challenge9BytecodeBase + nftFlagsAddress.slice(2).padStart(64, "0");
const deployerSigner = await hre.ethers.getSigner(deployer);
const nonce = await deployerSigner.getNonce();

const feeData = await hre.ethers.provider.getFeeData();
const rawTx = {
    nonce: nonce,
    maxFeePerGas: feeData.maxFeePerGas,
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
    gasLimit: 800_000,
    to: null,
    value: 0,
    data: challenge9Bytecode,
    chainId: (await hre.ethers.provider.getNetwork()).chainId,
};

const txResponse = await deployerSigner.sendTransaction(rawTx);
const txReceipt = await txResponse.wait();
const challenge9Address = txReceipt?.contractAddress;

if (challenge9Address) await save("Challenge9", { address: challenge9Address, abi: [] });

console.log("🚩 Challenge #9 deployed at:", challenge9Address);</code></pre>

What do you notice? Who is deploying this contract?
</details>

<details>
<summary>Hint 2</summary>
The bytecode has the line <code>PUSH18 0x424720435446204368616c6c656e67652039</code>. I wonder what this might do?
</details>

<details>
<summary>Hint 3</summary>
The contract has a function selector <code>0x23cfec7e</code>. Take a look at what it does - you can try using https://ethervm.io/decompile.
</details>

## Solution
<details>
<summary>Click to reveal solution</summary>

1. **Find the Private Key**:
   The deploy script uses the default Hardhat/Foundry mnemonic: `test test test test test test test test test test test junk`.
   The derivation path used for the signer is `m/44'/60'/0'/0/12`.
   Get the private key for this address.

2. **Construct the Message**:
   The hex chars `0x424720435446204368616c6c656e67652039` decode to `BG CTF Challenge 9`.
   Further down in the bytecode, we see the signing format: `keccak256(abi.encode("BG CTF Challenge 9", msg.sender))`

3. **Sign and Mint**:
   - Sign the eth-prefixed message hash with the leaked private key.
   - Call the function `0x23cfec7e` with the signer's address and the signature.

<pre><code>(bool success, ) = challenge9.call(
    abi.encodeWithSelector(0x23cfec7e, signerAddress, signature)
);</code></pre>

Why this works:
- The contract relies on a specific "trusted" signer to authorize mints.
- However, the "trusted" signer's key was generated from a public, insecure mnemonic committed in the deployment script.
</details>

## Why This Matters
**Hardcoded Secrets & Test Mnemonics**:
Never use default mnemonics or commit `.env` files containing real private keys to version control. If a deployment script containing a mnemonic (or pointing to a public one) is pushed to GitHub, any address derived from it is compromised immediately.

**Security Through Obscurity**:
[Security through obscurity](https://en.wikipedia.org/wiki/Security_through_obscurity) refers to the idea of making something secure by not revealing the implementation (in this case, the contract). However, any contract can be reverse engineered given enough of an incentive.

This is a variation of [S1C4: Who Can Sign This?](../../season1/challenge4), but obscured by the lack of source code and the indirect way the key was leaked, similar to [S1C8: The unverified](../../season1/challenge8).