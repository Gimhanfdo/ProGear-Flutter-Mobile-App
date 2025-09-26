import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartService {
  static const String baseUrl = "http://10.0.2.2:8000/api/cart";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get cart from API
  static Future<List<CartItem>> getCart() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['cart']['items'] as List;
      return data.map((item) {
        final product = Product.fromJson(item['product']);
        return CartItem(
          id: item['id'],
          product: product,
          quantity: item['quantity'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch cart: ${response.body}');
    }
  }

  // Add product to cart
  static Future<void> addItem(int productId, int quantity) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {
        'product_id': productId.toString(),
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add item: ${response.body}');
    }
  }

  // Update quantity of a cart item
  static Future<void> updateItem(int itemId, int quantity) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.put(
      Uri.parse("$baseUrl/update/$itemId"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'quantity': quantity.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item: ${response.body}');
    }
  }

  // Remove cart item
  static Future<void> removeItem(int itemId) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse("$baseUrl/remove/$itemId"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item: ${response.body}');
    }
  }

  // Clear entire cart
  static Future<void> clearCart() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse("$baseUrl/clear"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart: ${response.body}');
    }
  }
}
