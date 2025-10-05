import 'package:flutter/material.dart';

class NewsDetailsPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const NewsDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final String title = article["title"] ?? "No Title";
    final String description = article["description"] ?? "No Description";
    final String? imageUrl = article["urlToImage"];
    final String source = article["source"]["name"] ?? "Unknown Source";
    final String publishedAt = article["publishedAt"] ?? "";
    final String? imageAsset = article["imageAsset"];

    String formattedDate = "";
    if (publishedAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(publishedAt);
        formattedDate =
            "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
      } catch (e) {
        formattedDate = publishedAt;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("News Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((imageUrl != null) || (imageAsset != null))
              Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220,
                          )
                          : Image.asset(
                            imageAsset!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220,
                          ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.source, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        source,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
