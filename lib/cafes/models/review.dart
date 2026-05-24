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

  Review copyWith({
    String? id,
    String? cafeId,
    String? userId,
    String? authorName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? imageKey,
    String? imageUrl,
  }) {
    return Review(
      id: id ?? this.id,
      cafeId: cafeId ?? this.cafeId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      imageKey: imageKey ?? this.imageKey,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
