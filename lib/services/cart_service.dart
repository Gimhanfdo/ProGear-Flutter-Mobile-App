import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cart_item.dart';

class CartService {
  static const String baseUrl = "http://10.0.2.2:8000/api/cart";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get active cart
  static Future<List<CartItem>> getCart() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['cart']['items'] as List;
      return items.map((i) => CartItem.fromJson(i)).toList();
    } else {
      throw Exception("Failed to load cart: ${response.body}");
    }
  }

  // Add product
  static Future<void> addItem(int productId, int quantity) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'product_id': productId.toString(), 'quantity': quantity.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add item: ${response.body}");
    }
  }

  // Update item
  static Future<void> updateItem(int itemId, int quantity) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.put(
      Uri.parse("$baseUrl/update/$itemId"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'quantity': quantity.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update item: ${response.body}");
    }
  }

  // Remove item
  static Future<void> removeItem(int itemId) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse("$baseUrl/remove/$itemId"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove item: ${response.body}");
    }
  }

  // Clear cart
  static Future<void> clearCart() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse("$baseUrl/clear"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to clear cart: ${response.body}");
    }
  }
}
