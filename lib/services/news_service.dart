import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class NewsService {
  final url = Uri.parse('https://newsapi.org/v2/everything?q=international%20cricket&language=en&sortBy=publishedAt&pageSize=15&apiKey=36e4ab46c8254c1192ffcabdace26c62');

  // Function to fetch cricket news
  Future<List<dynamic>> fetchCricketNews() async {
    try {
      // Check internet connectivity
      var connectivityResult = await Connectivity().checkConnectivity();

      // If connected
      // ignore: unrelated_type_equality_checks
      if (connectivityResult != ConnectivityResult.none) {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data["articles"];
        } else {
          // Load fallback news if API fails
          return await loadFallbackNews();
        }
      } else {
        // Load fallback news if no network connectivity
        return await loadFallbackNews();
      }
    } catch (e) {
      return await loadFallbackNews();
    }
  }

  // Function to load fallback cricket news
  Future<List<dynamic>> loadFallbackNews() async {
    try {
      final String response = await rootBundle.loadString('assets/files/fallback_news.json');
      final data = json.decode(response);
      return data["articles"];
    } catch (e) {
      // Return an empty list if local loading fails
      return [];
    }
  }
}
