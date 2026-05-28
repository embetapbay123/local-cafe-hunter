import 'package:flutter_test/flutter_test.dart';

import 'package:local_cafe_hunter/cafes/repositories/local_cafe_repository.dart';
import 'package:local_cafe_hunter/cafes/viewmodels/cafe_viewmodel.dart';

void main() {
  group('CafeViewModel', () {
    test('filters cafes by search query and resets filters cleanly', () async {
      final viewModel = CafeViewModel(LocalCafeRepository());

      await viewModel.load();
      expect(viewModel.cafes, hasLength(2));

      viewModel.setSearchQuery('ther');
      expect(viewModel.visibleCafes, hasLength(1));
      expect(viewModel.visibleCafes.first.id, 'ther-coffee');
      expect(viewModel.hasActiveSearch, isTrue);

      viewModel.clearSearch();
      expect(viewModel.visibleCafes, hasLength(2));
      expect(viewModel.hasActiveSearch, isFalse);
    });

    test('refreshes nearby cafes and toggles favourites through repository',
        () async {
      final viewModel = CafeViewModel(LocalCafeRepository());

      await viewModel.load();
      await viewModel.setMapFocus(
        latitude: 16.0674,
        longitude: 108.2311,
        radiusMeters: 5000,
      );

      expect(viewModel.nearbyCafes, isNotEmpty);
      expect(viewModel.highlightedNearbyCafe?.id, 'ther-coffee');

      final before = viewModel.favouriteCafes.length;
      await viewModel.toggleFavourite('ther-coffee');
      expect(viewModel.favouriteCafes.length, before - 1);
    });
  });
}
