import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckoutService {
  final String baseUrl = "https://progear-laravel-website-production.up.railway.app/api/checkout";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchCheckoutData() async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: data,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Checkout API error: ${response.body}');
    }
  }
}
