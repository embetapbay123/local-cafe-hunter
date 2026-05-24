import '../data/local_cafe_seed.dart';
import '../models/cafe.dart';
import '../models/collection.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../utils/geo_math.dart';
import 'cafe_repository.dart';

class LocalCafeRepository implements CafeRepository {
  List<Cafe> _cafes = List<Cafe>.from(LocalCafeSeed.cafes);
  List<CafeCollection> _collections = List<CafeCollection>.from(
    LocalCafeSeed.collections,
  );
  UserProfile _userProfile = LocalCafeSeed.userProfile;

  @override
  Future<void> addReview(
    String cafeId,
    Review review, {
    String? imagePath,
  }) async {
    _cafes = _cafes.map((cafe) {
      if (cafe.id != cafeId) return cafe;
      final updatedReviews = [review, ...cafe.reviews];
      return _copyCafeWithUpdatedReviews(cafe, updatedReviews);
    }).toList();
  }

  @override
  Future<void> updateReview(String cafeId, Review review) async {
    _cafes = _cafes.map((cafe) {
      if (cafe.id != cafeId) return cafe;
      final updatedReviews = cafe.reviews.map((item) {
        if (item.id != review.id) return item;
        return review;
      }).toList();
      return _copyCafeWithUpdatedReviews(cafe, updatedReviews);
    }).toList();
  }

  @override
  Future<void> deleteReview(String cafeId, String reviewId) async {
    _cafes = _cafes.map((cafe) {
      if (cafe.id != cafeId) return cafe;
      final updatedReviews = cafe.reviews
          .where((item) => item.id != reviewId)
          .toList();
      return _copyCafeWithUpdatedReviews(cafe, updatedReviews);
    }).toList();
  }

  @override
  Future<Cafe?> getCafeById(String id) async {
    try {
      return _cafes.firstWhere((cafe) => cafe.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Cafe>> getCafes() async => List<Cafe>.from(_cafes);

  @override
  Future<List<CafeCollection>> getCollections() async =>
      List<CafeCollection>.from(_collections);

  @override
  Future<List<Cafe>> getFavouriteCafes() async {
    return _cafes.where((cafe) => cafe.isFavourite).toList();
  }

  @override
  Future<UserProfile> getUserProfile() async => _userProfile;

  @override
  Future<List<Review>> getReviewHistory() async {
    final reviews = _cafes.expand((cafe) => cafe.reviews).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<List<Cafe>> searchCafes({
    required String query,
    List<String> filters = const [],
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    return _cafes.where((cafe) {
      final queryMatches = normalizedQuery.isEmpty ||
          cafe.name.toLowerCase().contains(normalizedQuery) ||
          cafe.address.toLowerCase().contains(normalizedQuery);
      final filterMatches = filters.isEmpty ||
          filters.every(
            (filter) => cafe.amenities.any(
              (amenity) => amenity.toLowerCase() == filter.toLowerCase(),
            ),
          );
      return queryMatches && filterMatches;
    }).toList();
  }

  @override
  Future<List<Cafe>> getNearbyCafes({
    required double latitude,
    required double longitude,
    double radiusMeters = 2500,
    String query = '',
    List<String> filters = const [],
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedFilters = filters.map((filter) => filter.toLowerCase());

    final nearbyCafes = _cafes.map((cafe) {
      final distanceMeters = calculateDistanceMeters(
        startLatitude: latitude,
        startLongitude: longitude,
        endLatitude: cafe.latitude,
        endLongitude: cafe.longitude,
      );

      return cafe.copyWith(distanceMeters: distanceMeters);
    }).where((cafe) {
      final queryMatches = normalizedQuery.isEmpty ||
          cafe.name.toLowerCase().contains(normalizedQuery) ||
          cafe.address.toLowerCase().contains(normalizedQuery);
      final filterMatches = normalizedFilters.isEmpty ||
          normalizedFilters.every(
            (filter) => cafe.amenities.any(
              (amenity) => amenity.toLowerCase() == filter,
            ),
          );
      final distanceMatches = (cafe.distanceMeters ?? double.infinity) <=
          radiusMeters;
      return queryMatches && filterMatches && distanceMatches;
    }).toList()
      ..sort((left, right) {
        final leftDistance = left.distanceMeters ?? double.infinity;
        final rightDistance = right.distanceMeters ?? double.infinity;
        return leftDistance.compareTo(rightDistance);
      });

    return nearbyCafes;
  }

  @override
  Future<void> toggleFavourite(String cafeId) async {
    _cafes = _cafes.map((cafe) {
      if (cafe.id != cafeId) return cafe;
      return cafe.copyWith(isFavourite: !cafe.isFavourite);
    }).toList();
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final normalizedProfile = profile.copyWith(
      displayName: profile.displayName.trim(),
      tagline: profile.tagline.trim(),
      email: profile.email.trim(),
      phone: profile.phone.trim(),
      avatarKey: profile.avatarKey.trim(),
    );

    _userProfile = normalizedProfile;
    _cafes = _cafes.map((cafe) {
      final updatedReviews = cafe.reviews.map((review) {
        if (review.userId != normalizedProfile.userId) {
          return review;
        }
        return Review(
          id: review.id,
          cafeId: review.cafeId,
          userId: review.userId,
          authorName: normalizedProfile.displayName,
          rating: review.rating,
          comment: review.comment,
          createdAt: review.createdAt,
          imageKey: review.imageKey,
          imageUrl: review.imageUrl,
        );
      }).toList();

      return cafe.copyWith(reviews: updatedReviews);
    }).toList();
  }

  @override
  Future<void> createCollection(String name, List<String> cafeIds) async {
    _collections = [
      ..._collections,
      CafeCollection(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        cafeIds: List<String>.from(cafeIds.toSet()),
      ),
    ];
  }

  @override
  Future<void> renameCollection(String collectionId, String name) async {
    _collections = _collections.map((collection) {
      if (collection.id != collectionId) return collection;
      return collection.copyWith(name: name.trim());
    }).toList();
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    _collections = _collections
        .where((collection) => collection.id != collectionId)
        .toList();
  }

  @override
  Future<void> addCafeToCollection(String collectionId, String cafeId) async {
    _collections = _collections.map((collection) {
      if (collection.id != collectionId) return collection;
      if (collection.cafeIds.contains(cafeId)) return collection;
      return collection.copyWith(
        cafeIds: [...collection.cafeIds, cafeId],
      );
    }).toList();
  }

  @override
  Future<void> removeCafeFromCollection(
    String collectionId,
    String cafeId,
  ) async {
    _collections = _collections.map((collection) {
      if (collection.id != collectionId) return collection;
      return collection.copyWith(
        cafeIds: collection.cafeIds.where((id) => id != cafeId).toList(),
      );
    }).toList();
  }

  Cafe _copyCafeWithUpdatedReviews(Cafe cafe, List<Review> reviews) {
    final average = reviews.isEmpty
        ? 0.0
        : reviews.map((item) => item.rating).reduce((left, right) => left + right) /
            reviews.length;
    return cafe.copyWith(
      reviews: reviews,
      reviewCount: reviews.length,
      rating: reviews.isEmpty
          ? cafe.rating
          : double.parse(average.toStringAsFixed(1)),
    );
  }
}
