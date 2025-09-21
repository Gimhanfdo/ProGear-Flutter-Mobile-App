import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';

class ProductService {
  static const String baseUrl = "http://10.0.2.2:8000/api/products";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  //Function to fetch discounted products
  static Future<List<Product>> getDiscountedProducts() async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/discounted'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load discounted products. ${response.body}');
    }
  }

  //Function to fetch products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse("$baseUrl/category/$category"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load products by category");
    }
  }

  //Function to fetch a single product
  static Future<Product> getProductById(int id) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Product.fromJson(json);
    } else {
      throw Exception("Failed to load product details");
    }
  }
}
