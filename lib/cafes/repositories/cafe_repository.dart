import '../models/cafe.dart';
import '../models/cafe_catalog_sync_report.dart';
import '../models/collection.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

abstract class CafeRepository {
  Future<List<Cafe>> getCafes();
  Future<CafeCatalogSyncReport> syncCatalog({bool forceRefresh = false});
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
  Future<void> updateReview(String cafeId, Review review);
  Future<void> deleteReview(String cafeId, String reviewId);
  Future<void> createCollection(String name, List<String> cafeIds);
  Future<void> renameCollection(String collectionId, String name);
  Future<void> deleteCollection(String collectionId);
  Future<void> addCafeToCollection(String collectionId, String cafeId);
  Future<void> removeCafeFromCollection(String collectionId, String cafeId);
  Future<void> updateUserProfile(UserProfile profile);
}
