import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/cart_item.dart';
import 'package:progear_mobileapp/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    _items = await CartService.getCart();
    _isLoading = false;
    notifyListeners();
  }

  //Function to check if product is already added to cart
  bool isInCart(int productId) {
    return _items.any((item) => item.product.productID == productId);
  }

  Future<void> addItem(int productId, int quantity) async {
    await CartService.addItem(productId, quantity);
    await fetchCart();
  }

  Future<void> updateItem(int itemId, int quantity) async {
    await CartService.updateItem(itemId, quantity);
    await fetchCart();
  }

  Future<void> removeItem(int itemId) async {
    await CartService.removeItem(itemId);
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    await CartService.clearCart();
    _items.clear();
    notifyListeners();
  }
}
