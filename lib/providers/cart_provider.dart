import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {}; // Key: productId
  Map<int, CartItem> get items => _items;

  double get subTotal {
    return _items.values.fold(
      0,
      (sum, item) => sum + _unitPrice(item) * item.quantity,
    );
  }

  double get vatValue => subTotal * 0.18;
  double get total => subTotal + vatValue;

  double _unitPrice(CartItem item) {
    if (item.product.discountPercentage != null &&
        item.product.discountPercentage! > 0) {
      return item.product.price * (1 - item.product.discountPercentage! / 100);
    }
    return item.product.price;
  }

  bool isInCart(int productId) {
    return _items.containsKey(productId);
  }

  /// 🔹 Fetch cart from API
  Future<void> fetchCart() async {
    try {
      final cartItems = await CartService.getCart();
      _items = {
        for (var item in cartItems) item.product.productID: item,
      };
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch cart: $e");
    }
  }

  /// 🔹 Add item to cart
  Future<void> addItem(int productId, int quantity) async {
    try {
      await CartService.addItem(productId, quantity);
      await fetchCart(); // refresh cart after adding
    } catch (e) {
      throw Exception("Failed to add item: $e");
    }
  }

  /// 🔹 Update item quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    if (!_items.containsKey(productId)) return;

    try {
      final cartItemId = _items[productId]!.id;
      await CartService.updateItem(cartItemId, quantity);
      _items[productId]!.quantity = quantity;
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update quantity: $e");
    }
  }

  /// 🔹 Remove item
  Future<void> removeItem(int productId) async {
    if (!_items.containsKey(productId)) return;

    try {
      final cartItemId = _items[productId]!.id;
      await CartService.removeItem(cartItemId);
      _items.remove(productId);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to remove item: $e");
    }
  }

  /// 🔹 Clear entire cart
  Future<void> clearCart() async {
    try {
      await CartService.clearCart();
      _items.clear();
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to clear cart: $e");
    }
  }
}
