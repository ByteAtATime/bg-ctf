# BuidlGuidl CTF

This is my solution/guide repository for the [BuidlGuidl Capture the Flag (CTF)](https://ctf.buidlguidl.com/) challenges. They are designed to teach various Ethereum security concepts and smart contract vulnerabilities.

## Repository Structure

The challenges themselves are located in the `src/` directory, taken directly from [the CTF's repository](https://github.com/BuidlGuidl/ctf-devcon/tree/main/packages/hardhat/contracts).

The solutions and guides are located in the `test/` directory, with each challenge having its own subdirectory. In each subdirectory, there is a `README.md` file that explains the challenge and a general solution, as well as a `ChallengeX.t.sol` file that contains an implementation of the solution.

## Challenges

### Season 1
- [Challenge 1: The Greeting](./test/season1/challenge1)
- [Challenge 2: Just Call Me Maybe](./test/season1/challenge2)
- [Challenge 3: Empty Contract?](./test/season1/challenge3)
- [Challenge 4: Who Can Sign This?](./test/season1/challenge4)
- [Challenge 5: Give Me My Points!](./test/season1/challenge5)
- [Challenge 6: Meet All The Conditions](./test/season1/challenge6)
- [Challenge 7: Delegate](./test/season1/challenge7)
- [Challenge 8: The Unverified](./test/season1/challenge8)
- [Challenge 9: Password Protected](./test/season1/challenge9)
- [Challenge 10: Give 1 Get 1](./test/season1/challenge10)
- [Challenge 11: Who Can Call Me?](./test/season1/challenge11)
- [Challenge 12: Give Me The Block!](./test/season1/challenge12)

### Season 2
- [Challenge 1: The Greeting](./test/season2/challenge1)
- [Challenge 2: Show Me Your Key](./test/season2/challenge2)
- [Challenge 3: Let Me In!](./test/season2/challenge3)
- [Challenge 4: Pay Me!](./test/season2/challenge4)
- [Challenge 5: Count My Assembly](./test/season2/challenge5)
- [Challenge 6: Give Me My Points!](./test/season2/challenge6)
- [Challenge 7: Calldata FTW](./test/season2/challenge7)
- [Challenge 8: Locked](./test/season2/challenge8)
- [Challenge 9: The Unverified](./test/season2/challenge9)
- [Challenge 10: Who Can Call Me?](./test/season2/challenge10)
- [Challenge 11: Give Me The Block!](./test/season2/challenge11)
- [Challenge 12: Conquer The Game](./test/season2/challenge12)

## Running the Solutions

This repository uses [Foundry](https://getfoundry.sh/). If you would like to tinker with this repository, you should install Foundry and clone the repository:

```bash
git clone https://github.com/ByteAtATime/bg-ctf.git
```

Then, you have to install the dependencies (be patient, this may take a while):

```bash
forge install
```

Finally, you can run the tests:

```bash
forge test
```
