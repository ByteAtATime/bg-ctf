# BuidlGuidl CTF

This is my solution/guide repository for the [BuidlGuidl Capture the Flag (CTF)](https://ctf.buidlguidl.com/) challenges. They are designed to teach various Ethereum security concepts and smart contract vulnerabilities.

## Repository Structure

The challenges themselves are located in the `src/` directory, taken directly from [the CTF's repository](https://github.com/BuidlGuidl/ctf-devcon/tree/main/packages/hardhat/contracts).

The solutions and guides are located in the `test/` directory, with each challenge having its own subdirectory. In each subdirectory, there is a `README.md` file that explains the challenge and a general solution, as well as a `ChallengeX.t.sol` file that contains an implementation of the solution.

## Challenges

- [Challenge 1](./test/challenge1)
- [Challenge 2](./test/challenge2)
- [Challenge 3](./test/challenge3)
- [Challenge 4](./test/challenge4)
- [Challenge 5](./test/challenge5)
- [Challenge 6](./test/challenge6)
- [Challenge 7](./test/challenge7)
- [Challenge 8](./test/challenge8)
- [Challenge 9](./test/challenge9)
- [Challenge 10](./test/challenge10)
- [Challenge 11](./test/challenge11)
- [Challenge 12](./test/challenge12)

## Running the Solutions

This repository uses [Foundry](https://getfoundry.sh/). If you would like to tinker with this repository, you should install Foundry and clone the repository:

```bash
git clone https://github.com/ByteAtATime/bg-ctf.git
```

Then, you have to install the dependencies (be patient, this may take a while):

```bash
foundry install
```

Finally, you can run the tests:

```bash
foundry test
```
