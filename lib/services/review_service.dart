import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/review.dart';

class ReviewService {
  static const String baseUrl = "http://10.0.2.2:8000/api/reviews";
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Fetch all reviews for a product
  static Future<List<Review>> getProductReviews(int productId) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse("$baseUrl/$productId"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load reviews: ${response.body}");
    }
  }

  // Submit a new review
  static Future<bool> submitReview(
    int productId,
    int rating,
    String text,
  ) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse("$baseUrl/$productId"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'review_rating': rating.toString(),
        'review_text': text,
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to submit review");
    }
  }
}
