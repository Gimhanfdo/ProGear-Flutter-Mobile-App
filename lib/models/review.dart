class Review {
  final int id;
  final int userId;
  final String userName;
  final String reviewText;
  final int reviewRating;
  final String reviewDate;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.reviewText,
    required this.reviewRating,
    required this.reviewDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user']?['name'] ?? 'Anonymous',
      reviewText: json['review_text'],
      reviewRating: json['review_rating'],
      reviewDate: json['review_date'],
    );
  }
}
