import '../models/cafe.dart';
import '../models/collection.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

abstract class CafeRepository {
  Future<List<Cafe>> getCafes();
  Future<Cafe?> getCafeById(String id);
  Future<List<Cafe>> searchCafes({
    required String query,
    List<String> filters = const [],
  });
  Future<List<Cafe>> getNearbyCafes({
    required double latitude,
    required double longitude,
    double radiusMeters = 2500,
    String query = '',
    List<String> filters = const [],
  });
  Future<List<Cafe>> getFavouriteCafes();
  Future<List<Review>> getReviewHistory();
  Future<List<CafeCollection>> getCollections();
  Future<UserProfile> getUserProfile();
  Future<void> toggleFavourite(String cafeId);
  Future<void> addReview(
    String cafeId,
    Review review, {
    String? imagePath,
  });
  Future<void> createCollection(String name, List<String> cafeIds);
  Future<void> updateUserProfile(UserProfile profile);
}
