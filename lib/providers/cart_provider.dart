import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;

  CartItem({required this.id, required this.product, required this.quantity});
}

class CartProvider with ChangeNotifier {
  final String _baseUrl = "http://10.0.2.2:8000/api/cart";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  // Fetch cart from API
  Future<void> fetchCart() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['cart']['items'] as List;
      _items.clear();
      for (var item in data) {
        final productJson = item['product'];
        final product = Product.fromJson(productJson);
        final cartItemId = item['id']; // backend cart item ID
        _items[product.productID] = CartItem(
          id: cartItemId,
          product: product,
          quantity: item['quantity'],
        );
      }
      notifyListeners();
    } else {
      throw Exception('Failed to fetch cart: ${response.body}');
    }
  }

  // Add item to cart
  Future<void> addItem(int productId, int quantity) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'product_id': productId.toString(), 'quantity': quantity.toString()},
    );

    if (response.statusCode == 200) {
      await fetchCart(); // refresh cart after adding
    } else {
      throw Exception('Failed to add item: ${response.body}');
    }
  }

  // Update quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    if (!_items.containsKey(productId)) return;

    final cartItemId = _items[productId]!.id;
    final token = await _storage.read(key: 'auth_token');

    final response = await http.put(
      Uri.parse('$_baseUrl/update/$cartItemId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'quantity': quantity.toString()},
    );

    if (response.statusCode == 200) {
      _items[productId]!.quantity = quantity;
      notifyListeners();
    } else {
      throw Exception('Failed to update quantity: ${response.body}');
    }
  }

  // Remove item
  Future<void> removeItem(int productId) async {
    if (!_items.containsKey(productId)) return;

    final cartItemId = _items[productId]!.id;
    final token = await _storage.read(key: 'auth_token');

    final response = await http.delete(
      Uri.parse('$_baseUrl/remove/$cartItemId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      _items.remove(productId);
      notifyListeners();
    } else {
      throw Exception('Failed to remove item: ${response.body}');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.delete(
      Uri.parse('$_baseUrl/clear'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      _items.clear();
      notifyListeners();
    } else {
      throw Exception('Failed to clear cart: ${response.body}');
    }
  }
}
