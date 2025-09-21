import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Helper: get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Example: Fetch products
  Future<List<dynamic>> getProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  /// Example: Add to cart
  Future<bool> addToCart(int productId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: {
        'product_id': productId.toString(),
        'quantity': quantity.toString(),
      },
    );

    return response.statusCode == 200;
  }
}
