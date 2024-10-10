// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/TradingBook.sol"; // Assurez-vous que le chemin est correct

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000 * 10 ** decimals()); // Mint initial tokens to deployer
    }
}

contract TradingBookTest is Test {
    TradingBook public tradingBook;
    MockToken public asset1;
    MockToken public asset2;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        asset1 = new MockToken("Asset1", "AS1");
        asset2 = new MockToken("Asset2", "AS2");
        tradingBook = new TradingBook(address(asset1), address(asset2));

        // Mint tokens to users for testing
        asset1.transfer(user1, 1000 * 10 ** asset1.decimals());
        asset2.transfer(user2, 1000 * 10 ** asset2.decimals());
    }

    function test_placeBuyOrder() public {
        // User2 places a buy order for 100 Asset1 at price 5 Asset2
        vm.startPrank(user2);
        asset2.approve(address(tradingBook), 500 * 10 ** asset2.decimals());
        tradingBook.createOrder(100 * 10 ** asset1.decimals(), 5, true);

        // Get the order details
        (
            address user,
            uint256 quantity,
            uint256 unitPrice,
            bool isPurchase,
            bool isValid
        ) = tradingBook.getTradeOrder(0);

        assertEq(user, user2);
        assertEq(quantity, 100 * 10 ** asset1.decimals());
        assertEq(unitPrice, 5);
        assertTrue(isPurchase);
        assertTrue(isValid);
        vm.stopPrank();
    }

    function test_placeSellOrder() public {
        // User1 places a sell order for 100 Asset1 at price 5 Asset2
        vm.startPrank(user1);
        asset1.approve(address(tradingBook), 100 * 10 ** asset1.decimals());
        tradingBook.createOrder(100 * 10 ** asset1.decimals(), 5, false);

        // Get the order details
        (
            address user,
            uint256 quantity,
            uint256 unitPrice,
            bool isPurchase,
            bool isValid
        ) = tradingBook.getTradeOrder(0);

        assertEq(user, user1);
        assertEq(quantity, 100 * 10 ** asset1.decimals());
        assertEq(unitPrice, 5);
        assertFalse(isPurchase);
        assertTrue(isValid);
        vm.stopPrank();
    }

    function test_matchBuyOrder() public {
        // User2 places a buy order
        vm.startPrank(user2);
        asset2.approve(address(tradingBook), 500 * 10 ** asset2.decimals());
        tradingBook.createOrder(100 * 10 ** asset1.decimals(), 5, true);
        vm.stopPrank();

        // User1 places a sell order
        vm.startPrank(user1);
        asset1.approve(address(tradingBook), 100 * 10 ** asset1.decimals());
        tradingBook.createOrder(100 * 10 ** asset1.decimals(), 5, false);
        vm.stopPrank();

        // User1 matches the order
        vm.startPrank(user1);
        asset1.approve(address(tradingBook), 100 * 10 ** asset1.decimals());
        tradingBook.fulfillOrder(0, 100 * 10 ** asset1.decimals()); // Match the buy order
        vm.stopPrank();

        // Verify the order has been matched
        (
            address user,
            uint256 quantity,
            uint256 unitPrice,
            bool isPurchase,
            bool isValid
        ) = tradingBook.getTradeOrder(0);
        assertEq(quantity, 0); // The order should be filled
        assertFalse(isValid); // The order should not be active anymore
    }

    function test_cancelOrder() public {
        // User1 places a sell order
        vm.startPrank(user1);
        asset1.approve(address(tradingBook), 100 * 10 ** asset1.decimals());
        tradingBook.createOrder(100 * 10 ** asset1.decimals(), 5, false);
        uint256 orderId = 0; // The ID of the placed order
        vm.stopPrank();
    }
}
