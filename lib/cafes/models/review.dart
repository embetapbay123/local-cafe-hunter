class Review {
  const Review({
    required this.id,
    required this.cafeId,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.imageKey,
    this.imageUrl,
  });

  final String id;
  final String cafeId;
  final String userId;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? imageKey;
  final String? imageUrl;
}
