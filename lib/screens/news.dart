import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/shared/custom_app_bar.dart';
import '../services/news_service.dart';
import 'news_details.dart';
import '../utils/connectivity_helper.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService();
  late Future<List<dynamic>> _newsFuture; // Future that holds the list of news articles fetched

  @override
  void initState() {
    super.initState();
    showConnectivitySnackBar(context); // Show internet connectivity status using a SnackBar
    _newsFuture = _newsService.fetchCricketNews(); // Fetch cricket news when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handle error state 
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // Handle empty state 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No news available"));
          }

          final newsList = snapshot.data!; // List of news articles

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final article = newsList[index];
              final title = article["title"] ?? "No Title";
              final imageUrl = article["urlToImage"];
              final publishedAt = article["publishedAt"];
              final imageAsset = article["imageAsset"];

              // Format published date
              String formattedDate = "";
              if (publishedAt != null) {
                try {
                  final dateTime = DateTime.parse(publishedAt); // Format the published date
                  formattedDate =
                      "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
                } catch (e) {
                  formattedDate = publishedAt;
                }
              }

              // Each article is displayed as a card
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl, width: 60, fit: BoxFit.cover)
                      : Image.asset(imageAsset, width: 60, fit: BoxFit.cover),
                  title: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailsPage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
