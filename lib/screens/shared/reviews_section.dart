import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/review.dart';
import 'package:progear_mobileapp/services/review_service.dart';

class ReviewsSection extends StatefulWidget {
  final int productId;
  const ReviewsSection({super.key, required this.productId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late Future<List<Review>> _reviewsFuture; // Future variable to store the async reviews list

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService.getProductReviews(widget.productId); //Fetch the reviews when the widget initializes 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture, // The future that loads product reviews
      builder: (context, snapshot) { //Snapshot holds information about the current state of the async call
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state 
        else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        // Handle empty or no data state 
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "No reviews yet.",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Divider(color: theme.colorScheme.inversePrimary, thickness: 1),
              ],
            ),
          );
        }

        //Display reviews if they exist
        final reviews = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...reviews.map((review) {
                return Card( //Each review is displayed as a card widget
                  child: ListTile(
                    title: Text(review.userName),
                    subtitle: Text(review.reviewText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.reviewRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 5),
              Divider(color: theme.colorScheme.inversePrimary, thickness: 1),
            ],
          ),
        );
      },
    );
  }
}
