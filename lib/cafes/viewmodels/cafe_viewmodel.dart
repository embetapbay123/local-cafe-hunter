import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cafe.dart';
import '../models/collection.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../repositories/cafe_repository.dart';

enum CafeSortMode { relevance, ratingHigh, distanceNear, priceLow }

enum CafePriceFilter { any, budget, moderate, premium }

class CafeViewModel extends ChangeNotifier {
  CafeViewModel(this._repository);

  final CafeRepository _repository;
  static const _defaultMapRadiusMeters = 2500.0;

  bool _isLoading = true;
  bool _isMapLoading = false;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String? _selectedFilter;
  CafeSortMode _sortMode = CafeSortMode.relevance;
  CafePriceFilter _priceFilter = CafePriceFilter.any;
  String? _errorMessage;
  String? _mapErrorMessage;
  List<Cafe> _cafes = const [];
  List<Cafe> _nearbyCafes = const [];
  List<CafeCollection> _collections = const [];
  List<Review> _reviewHistory = const [];
  UserProfile? _userProfile;
  double? _mapCenterLatitude;
  double? _mapCenterLongitude;
  double _mapRadiusMeters = _defaultMapRadiusMeters;

  bool get isLoading => _isLoading;
  bool get isMapLoading => _isMapLoading;
  int get selectedTabIndex => _selectedTabIndex;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  CafeSortMode get sortMode => _sortMode;
  CafePriceFilter get priceFilter => _priceFilter;
  String? get errorMessage => _errorMessage;
  String? get mapErrorMessage => _mapErrorMessage;
  double? get mapCenterLatitude => _mapCenterLatitude;
  double? get mapCenterLongitude => _mapCenterLongitude;
  double get mapRadiusMeters => _mapRadiusMeters;
  List<Cafe> get cafes => List<Cafe>.unmodifiable(_cafes);
  List<Cafe> get nearbyCafes => List<Cafe>.unmodifiable(_nearbyCafes);
  List<CafeCollection> get collections =>
      List<CafeCollection>.unmodifiable(_collections);
  List<Review> get reviewHistory => List<Review>.unmodifiable(_reviewHistory);
  UserProfile? get userProfile => _userProfile;

  List<String> get availableFilters {
    final filters = <String>{};
    for (final cafe in _cafes) {
      filters.addAll(cafe.amenities);
    }
    return filters.toList()..sort();
  }

  bool get hasActiveSearch =>
      _searchQuery.isNotEmpty ||
      _selectedFilter != null ||
      _sortMode != CafeSortMode.relevance ||
      _priceFilter != CafePriceFilter.any ||
      _mapRadiusMeters != _defaultMapRadiusMeters;

  List<Cafe> get visibleCafes {
    final filter = _selectedFilter;
    final filtered = _cafes.where((cafe) {
      final query = _searchQuery;
      final queryMatches = query.isEmpty ||
          cafe.name.toLowerCase().contains(query) ||
          cafe.address.toLowerCase().contains(query);
      final filterMatches =
          filter == null || cafe.amenities.any((item) => item == filter);
      return queryMatches && filterMatches;
    }).toList();
    return _applyAdvancedFiltersAndSort(filtered);
  }

  List<Cafe> get favouriteCafes =>
      _cafes.where((cafe) => cafe.isFavourite).toList();

  Cafe? get highlightedNearbyCafe =>
      _nearbyCafes.isEmpty ? null : _nearbyCafes.first;

  Cafe? getCafeById(String cafeId) {
    for (final cafe in _cafes) {
      if (cafe.id == cafeId) {
        return cafe;
      }
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cafes = await _repository.getCafes();
      _collections = await _repository.getCollections();
      _reviewHistory = await _repository.getReviewHistory();
      _userProfile = await _repository.getUserProfile();
      _initializeMapCenter();
      await _loadNearbyCafes(notify: false);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> refreshNearbyCafes() async {
    await _loadNearbyCafes();
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    final normalized = value.trim().toLowerCase();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    unawaited(_loadNearbyCafes());
    notifyListeners();
  }

  void setSelectedFilter(String? filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    unawaited(_loadNearbyCafes());
    notifyListeners();
  }

  void setSortMode(CafeSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    unawaited(_loadNearbyCafes());
    notifyListeners();
  }

  void setPriceFilter(CafePriceFilter filter) {
    if (_priceFilter == filter) return;
    _priceFilter = filter;
    unawaited(_loadNearbyCafes());
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty &&
        _selectedFilter == null &&
        _sortMode == CafeSortMode.relevance &&
        _priceFilter == CafePriceFilter.any &&
        _mapRadiusMeters == _defaultMapRadiusMeters) {
      return;
    }
    _searchQuery = '';
    _selectedFilter = null;
    _sortMode = CafeSortMode.relevance;
    _priceFilter = CafePriceFilter.any;
    _mapRadiusMeters = _defaultMapRadiusMeters;
    unawaited(_loadNearbyCafes());
    notifyListeners();
  }

  Future<void> setMapFocus({
    required double latitude,
    required double longitude,
    double? radiusMeters,
  }) async {
    _mapCenterLatitude = latitude;
    _mapCenterLongitude = longitude;
    if (radiusMeters != null) {
      _mapRadiusMeters = radiusMeters;
    }
    await _loadNearbyCafes();
  }

  Future<void> toggleFavourite(String cafeId) async {
    await _repository.toggleFavourite(cafeId);
    _cafes = await _repository.getCafes();
    await _loadNearbyCafes(notify: false);
    notifyListeners();
  }

  Future<void> addReview({
    required String cafeId,
    required double rating,
    required String comment,
  }) async {
    final profile = _userProfile;
    final review = Review(
      id: 'review-${DateTime.now().microsecondsSinceEpoch}',
      cafeId: cafeId,
      userId: profile?.userId ?? 'local-demo-user',
      authorName: profile?.displayName ?? 'Local Hunter',
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );

    await _repository.addReview(cafeId, review);
    _cafes = await _repository.getCafes();
    _reviewHistory = await _repository.getReviewHistory();
    await _loadNearbyCafes(notify: false);
    notifyListeners();
  }

  Future<void> updateReview({
    required String cafeId,
    required Review review,
    required double rating,
    required String comment,
  }) async {
    await _repository.updateReview(
      cafeId,
      review.copyWith(
        rating: rating,
        comment: comment.trim(),
      ),
    );
    _cafes = await _repository.getCafes();
    _reviewHistory = await _repository.getReviewHistory();
    await _loadNearbyCafes(notify: false);
    notifyListeners();
  }

  Future<void> deleteReview({
    required String cafeId,
    required String reviewId,
  }) async {
    await _repository.deleteReview(cafeId, reviewId);
    _cafes = await _repository.getCafes();
    _reviewHistory = await _repository.getReviewHistory();
    await _loadNearbyCafes(notify: false);
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _repository.updateUserProfile(profile);
    _userProfile = await _repository.getUserProfile();
    _cafes = await _repository.getCafes();
    _reviewHistory = await _repository.getReviewHistory();
    await _loadNearbyCafes(notify: false);
    notifyListeners();
  }

  Future<void> createCollection(String name, List<String> cafeIds) async {
    await _repository.createCollection(name, cafeIds);
    _collections = await _repository.getCollections();
    notifyListeners();
  }

  Future<void> renameCollection(String collectionId, String name) async {
    await _repository.renameCollection(collectionId, name);
    _collections = await _repository.getCollections();
    notifyListeners();
  }

  Future<void> deleteCollection(String collectionId) async {
    await _repository.deleteCollection(collectionId);
    _collections = await _repository.getCollections();
    notifyListeners();
  }

  Future<void> addCafeToCollection(String collectionId, String cafeId) async {
    await _repository.addCafeToCollection(collectionId, cafeId);
    _collections = await _repository.getCollections();
    notifyListeners();
  }

  Future<void> removeCafeFromCollection(
    String collectionId,
    String cafeId,
  ) async {
    await _repository.removeCafeFromCollection(collectionId, cafeId);
    _collections = await _repository.getCollections();
    notifyListeners();
  }

  void _initializeMapCenter() {
    if (_cafes.isEmpty) {
      _mapCenterLatitude = null;
      _mapCenterLongitude = null;
      return;
    }

    final latitudeAverage =
        _cafes.map((cafe) => cafe.latitude).reduce((left, right) => left + right) /
            _cafes.length;
    final longitudeAverage =
        _cafes.map((cafe) => cafe.longitude).reduce((left, right) => left + right) /
            _cafes.length;

    _mapCenterLatitude = latitudeAverage;
    _mapCenterLongitude = longitudeAverage;
  }

  Future<void> _loadNearbyCafes({bool notify = true}) async {
    final latitude = _mapCenterLatitude;
    final longitude = _mapCenterLongitude;
    if (latitude == null || longitude == null) {
      _nearbyCafes = const [];
      _mapErrorMessage = 'Map center is not ready yet.';
      if (notify) notifyListeners();
      return;
    }

    _isMapLoading = true;
    _mapErrorMessage = null;
    if (notify) notifyListeners();

    try {
      final nearby = await _repository.getNearbyCafes(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: _mapRadiusMeters,
        query: _searchQuery,
        filters: _selectedFilter == null ? const [] : [_selectedFilter!],
      );
      _nearbyCafes = _applyAdvancedFiltersAndSort(nearby);
    } catch (error) {
      _mapErrorMessage = error.toString();
    } finally {
      _isMapLoading = false;
      if (notify) notifyListeners();
    }
  }

  List<Cafe> _applyAdvancedFiltersAndSort(List<Cafe> cafes) {
    final filtered = cafes.where(_matchesPriceFilter).toList();
    switch (_sortMode) {
      case CafeSortMode.relevance:
        return filtered;
      case CafeSortMode.ratingHigh:
        filtered.sort((left, right) => right.rating.compareTo(left.rating));
        return filtered;
      case CafeSortMode.distanceNear:
        filtered.sort((left, right) {
          final leftDistance = left.distanceMeters ?? double.infinity;
          final rightDistance = right.distanceMeters ?? double.infinity;
          return leftDistance.compareTo(rightDistance);
        });
        return filtered;
      case CafeSortMode.priceLow:
        filtered.sort((left, right) {
          return _maxPriceValue(left.priceRange).compareTo(
            _maxPriceValue(right.priceRange),
          );
        });
        return filtered;
    }
  }

  bool _matchesPriceFilter(Cafe cafe) {
    final maxPrice = _maxPriceValue(cafe.priceRange);
    switch (_priceFilter) {
      case CafePriceFilter.any:
        return true;
      case CafePriceFilter.budget:
        return maxPrice <= 40000;
      case CafePriceFilter.moderate:
        return maxPrice > 40000 && maxPrice <= 55000;
      case CafePriceFilter.premium:
        return maxPrice > 55000;
    }
  }

  int _maxPriceValue(String priceRange) {
    final compact = priceRange.replaceAll(' ', '').toLowerCase();
    final parts = compact.split('-');
    final last = parts.isEmpty ? compact : parts.last;
    final digits = last.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return 0;
    }
    return int.parse(digits) * 1000;
  }
}
