import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/shared/custom_app_bar.dart';
import '../services/news_service.dart';
import 'news_details.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService();
  late Future<List<dynamic>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchCricketNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No news available"));
          }

          final newsList = snapshot.data!;

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final article = newsList[index];
              final title = article["title"] ?? "No Title";
              final imageUrl = article["urlToImage"];
              final publishedAt = article["publishedAt"];

              // Format published date
              String formattedDate = "";
              if (publishedAt != null) {
                try {
                  final dateTime = DateTime.parse(publishedAt);
                  formattedDate =
                      "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
                } catch (e) {
                  formattedDate = publishedAt;
                }
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl, width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.article, size: 40),
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
