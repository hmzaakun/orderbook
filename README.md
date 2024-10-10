# 📊 TradingBook Smart Contract

Welcome to the **TradingBook** smart contract! This contract implements a decentralized order book system where users can trade assets (like tokens) on the blockchain. Below is a detailed explanation of the contract logic and how it works.

## 🔍 Overview

The **TradingBook** contract is designed to allow users to place buy and sell orders for two different ERC20 tokens, like **BTC** and **USDC**. It maintains a **decentralized order book** where users can interact by placing, fulfilling, and checking orders.

## 📜 Key Components

1. **Assets (Tokens)** 🎟️:

   - `asset1`: The first token in the pair (e.g., **BTC**).
   - `asset2`: The second token in the pair (e.g., **USDC**).
   - The constructor ensures that both tokens are different and valid.

2. **Trade Orders** 🛒:

   - The contract allows users to create **buy** or **sell** orders.
   - Orders are stored in a structure called `TradeOrder`, which tracks:
     - `user`: The address of the user who placed the order.
     - `quantity`: The amount of tokens to trade.
     - `unitPrice`: The price per token (for buy or sell).
     - `isPurchase`: `true` if it's a buy order, `false` if it's a sell order.
     - `isValid`: `true` if the order is still active, `false` if it has been filled or canceled.

3. **Order Creation** 📝:

   - **Buy Orders**: When a user places a buy order, they transfer the required amount of `asset2` (e.g., USDC) to the contract.
   - **Sell Orders**: When a user places a sell order, they transfer the required amount of `asset1` (e.g., BTC) to the contract.
   - The contract checks that the user has enough balance and that the tokens are transferred correctly.

4. **Fulfilling Orders** 🤝:

   - Other users can fulfill an order, either partially or completely, by sending the required tokens:
     - **Buy Order**: The seller sends `asset1` (e.g., BTC) and receives the payment in `asset2` (e.g., USDC).
     - **Sell Order**: The buyer sends `asset2` (e.g., USDC) and receives the tokens in `asset1` (e.g., BTC).
   - The order's quantity is adjusted, and if fully filled, the order is marked as **invalid** (no longer active).

5. **Viewing Orders** 👀:
   - Users can call `getTradeOrder` to view the details of any order using its unique order ID. It returns:
     - The address of the user who placed the order.
     - The remaining quantity of tokens in the order.
     - The unit price.
     - Whether it is a buy or sell order.
     - Whether the order is still valid.

## 🔧 Functions

### 1. `createOrder`

- **Purpose**: Allows users to create a new buy or sell order.
- **Parameters**:
  - `_quantity`: The number of tokens the user wants to trade.
  - `_unitPrice`: The price per token.
  - `_isPurchase`: `true` for buy orders, `false` for sell orders.
- **Functionality**:
  - Transfers tokens from the user to the contract depending on the order type.
  - Adds the new order to the `tradingBook` mapping and assigns it a unique order ID.

### 2. `fulfillOrder`

- **Purpose**: Allows a user to fulfill an existing order partially or fully.
- **Parameters**:
  - `_orderId`: The ID of the order to fulfill.
  - `_quantityToTrade`: The amount of tokens to trade from the order.
- **Functionality**:
  - Executes the trade by transferring tokens between the buyer and the seller.
  - Adjusts the remaining quantity in the order.
  - Marks the order as invalid if fully filled.

### 3. `getTradeOrder`

- **Purpose**: Retrieve the details of a specific order.
- **Parameters**:
  - `_orderId`: The ID of the order to retrieve.
- **Returns**: Details of the order including user, quantity, price, and status.

## 🎯 Example Workflow

1. **User1** creates a buy order to purchase 100 BTC at 50000 USDC per BTC.
   - User1 transfers 5,000,000 USDC to the contract.
2. **User2** fulfills part of this order by selling 50 BTC.
   - User2 sends 50 BTC and receives 2,500,000 USDC.
   - The order is updated to reflect that only 50 BTC are left to be bought.
3. **User3** can fulfill the remaining 50 BTC in a separate transaction.

## 🚀 Features

- Fully decentralized trading between two ERC20 tokens.
- Support for partial or complete fulfillment of orders.
- Safe token transfers with checks for balances and approvals.
- Easy order management and retrieval.

## 🔒 Security

- Users cannot fulfill their own orders to prevent self-dealing.
- The contract ensures that all transfers are successful before finalizing any order creation or fulfillment.
