import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {

  //Function to fetch cricket news from NewsAPI
  Future<List<dynamic>> fetchCricketNews() async {
    final url = Uri.parse('https://newsapi.org/v2/everything?q=international%20cricket&language=en&sortBy=publishedAt&pageSize=15&apiKey=36e4ab46c8254c1192ffcabdace26c62');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["articles"]; 
    } else {
      throw Exception("Failed to fetch cricket news");
    }
  }
}
