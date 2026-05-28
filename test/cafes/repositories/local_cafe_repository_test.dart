import 'package:flutter_test/flutter_test.dart';

import 'package:local_cafe_hunter/cafes/data/local_cafe_seed.dart';
import 'package:local_cafe_hunter/cafes/models/review.dart';
import 'package:local_cafe_hunter/cafes/repositories/local_cafe_repository.dart';

void main() {
  group('LocalCafeRepository', () {
    test('loads the bundled cafe seed and searches by query', () async {
      final repository = LocalCafeRepository();

      final cafes = await repository.getCafes();
      expect(cafes, hasLength(LocalCafeSeed.cafes.length));

      final results = await repository.searchCafes(query: 'ther');
      expect(results, hasLength(1));
      expect(results.first.id, 'ther-coffee');
    });

    test('returns nearby cafes sorted by distance', () async {
      final repository = LocalCafeRepository();

      final nearby = await repository.getNearbyCafes(
        latitude: 16.0674,
        longitude: 108.2311,
        radiusMeters: 5000,
      );

      expect(nearby, isNotEmpty);
      expect(nearby.first.id, 'ther-coffee');
      expect(nearby.first.distanceMeters, closeTo(0, 0.001));
    });

    test('toggles favourites and stores new reviews', () async {
      final repository = LocalCafeRepository();

      await repository.toggleFavourite('ther-coffee');
      final cafesAfterFavouriteToggle = await repository.getCafes();
      final therCafe = cafesAfterFavouriteToggle.firstWhere(
        (cafe) => cafe.id == 'ther-coffee',
      );
      expect(therCafe.isFavourite, isFalse);

      final review = Review(
        id: 'review-new',
        cafeId: 'ther-coffee',
        userId: 'local-demo-user',
        authorName: 'Tester',
        rating: 5,
        comment: 'Rat tot.',
        createdAt: DateTime(2026, 5, 1),
      );

      await repository.addReview('ther-coffee', review);
      final updatedCafe = (await repository.getCafes()).firstWhere(
        (cafe) => cafe.id == 'ther-coffee',
      );
      expect(updatedCafe.reviews.first.id, 'review-new');
      expect(updatedCafe.reviewCount, 2);
      expect(updatedCafe.rating, 4.8);
    });
  });
}
