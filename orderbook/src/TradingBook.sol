// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradingBook {
    IERC20 public asset1; // Premier actif de la paire (ex: BTC)
    IERC20 public asset2; // Deuxième actif de la paire (ex: USDC)

    constructor(address _asset1, address _asset2) {
        require(
            _asset1 != address(0) && _asset2 != address(0),
            "Invalid asset addresses"
        );
        require(_asset1 != _asset2, "Assets must be different");

        asset1 = IERC20(_asset1);
        asset2 = IERC20(_asset2);
    }

    // Structure pour un ordre de trading
    struct TradeOrder {
        address user; // Adresse de l'utilisateur qui a placé l'ordre
        uint256 quantity; // Quantité d'actifs dans l'ordre
        uint256 unitPrice; // Prix unitaire des actifs
        bool isPurchase; // True pour un ordre d'achat, False pour un ordre de vente
        bool isValid; // True si l'ordre est encore valide, False s'il est exécuté
    }

    // Carnet de commandes (order book) avec un `mapping` pour un accès rapide
    mapping(uint256 => TradeOrder) public tradingBook;
    uint256 public orderIdCounter; // Compteur pour l'identifiant des ordres

    // Placer un ordre d'achat ou de vente
    function createOrder(
        uint256 _quantity,
        uint256 _unitPrice,
        bool _isPurchase
    ) public {
        require(_quantity > 0, "Quantity must be greater than 0");
        require(_unitPrice > 0, "Unit price must be greater than 0");

        if (_isPurchase) {
            // Si c'est un ordre d'achat, l'utilisateur doit envoyer les actifs asset2 (ex: USDC)
            uint256 totalPayment = _quantity * _unitPrice;
            require(
                asset2.transferFrom(msg.sender, address(this), totalPayment),
                "Payment failed"
            );
        } else {
            // Si c'est un ordre de vente, l'utilisateur doit envoyer les actifs asset1 (ex: BTC)
            require(
                asset1.transferFrom(msg.sender, address(this), _quantity),
                "Transfer failed"
            );
        }

        // Créer et ajouter l'ordre au carnet
        TradeOrder memory newTradeOrder = TradeOrder({
            user: msg.sender,
            quantity: _quantity,
            unitPrice: _unitPrice,
            isPurchase: _isPurchase,
            isValid: true
        });

        tradingBook[orderIdCounter] = newTradeOrder;
        orderIdCounter++;
    }

    // Faire correspondre un ordre (partiellement ou totalement)
    function fulfillOrder(uint256 _orderId, uint256 _quantityToTrade) public {
        TradeOrder storage tradeOrder = tradingBook[_orderId];
        require(tradeOrder.isValid, "Order is not valid");
        require(tradeOrder.user != msg.sender, "Cannot fulfill your own order");
        require(
            _quantityToTrade <= tradeOrder.quantity,
            "Quantity exceeds order size"
        );
        require(_quantityToTrade > 0, "Quantity must be greater than 0");

        uint256 totalPayment = _quantityToTrade * tradeOrder.unitPrice;

        if (tradeOrder.isPurchase) {
            // Si c'est un ordre d'achat, vérifier que le vendeur envoie les bons actifs (asset1)
            require(
                asset1.transferFrom(
                    msg.sender,
                    tradeOrder.user,
                    _quantityToTrade
                ),
                "Transfer of asset1 failed"
            );
            require(
                asset2.transfer(msg.sender, totalPayment),
                "Transfer of asset2 failed"
            );
        } else {
            // Si c'est un ordre de vente, vérifier que l'acheteur envoie les bons actifs (asset2)
            require(
                asset2.transferFrom(msg.sender, tradeOrder.user, totalPayment),
                "Transfer of asset2 failed"
            );
            require(
                asset1.transfer(msg.sender, _quantityToTrade),
                "Transfer of asset1 failed"
            );
        }

        // Ajuster la quantité restante dans l'ordre
        tradeOrder.quantity -= _quantityToTrade;

        // Si l'ordre est entièrement rempli, le marquer comme inactif
        if (tradeOrder.quantity == 0) {
            tradeOrder.isValid = false;
        }
    }

    // Obtenir les détails d'un ordre spécifique
    function getTradeOrder(
        uint256 _orderId
    ) public view returns (address, uint256, uint256, bool, bool) {
        TradeOrder memory tradeOrder = tradingBook[_orderId];
        return (
            tradeOrder.user,
            tradeOrder.quantity,
            tradeOrder.unitPrice,
            tradeOrder.isPurchase,
            tradeOrder.isValid
        );
    }
}
