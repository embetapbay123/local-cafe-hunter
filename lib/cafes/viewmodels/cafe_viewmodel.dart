import 'package:flutter/foundation.dart';

import '../models/cafe.dart';
import '../models/collection.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../repositories/cafe_repository.dart';

class CafeViewModel extends ChangeNotifier {
  CafeViewModel(this._repository);

  final CafeRepository _repository;

  bool _isLoading = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  String? _selectedFilter;
  String? _errorMessage;
  List<Cafe> _cafes = const [];
  List<CafeCollection> _collections = const [];
  List<Review> _reviewHistory = const [];
  UserProfile? _userProfile;

  bool get isLoading => _isLoading;
  int get selectedTabIndex => _selectedTabIndex;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;
  List<Cafe> get cafes => List<Cafe>.unmodifiable(_cafes);
  List<CafeCollection> get collections =>
      List<CafeCollection>.unmodifiable(_collections);
  List<Review> get reviewHistory => List<Review>.unmodifiable(_reviewHistory);
  UserProfile? get userProfile => _userProfile;

  List<String> get availableFilters =>
      const ['Wifi manh', 'May lanh', 'Yen tinh'];

  List<Cafe> get visibleCafes {
    final filter = _selectedFilter;
    return _cafes.where((cafe) {
      final query = _searchQuery;
      final queryMatches = query.isEmpty ||
          cafe.name.toLowerCase().contains(query) ||
          cafe.address.toLowerCase().contains(query);
      final filterMatches =
          filter == null || cafe.amenities.any((item) => item == filter);
      return queryMatches && filterMatches;
    }).toList();
  }

  List<Cafe> get favouriteCafes =>
      _cafes.where((cafe) => cafe.isFavourite).toList();

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cafes = await _repository.getCafes();
      _collections = await _repository.getCollections();
      _reviewHistory = await _repository.getReviewHistory();
      _userProfile = await _repository.getUserProfile();
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

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    final normalized = value.trim().toLowerCase();
    if (_searchQuery == normalized) return;
    _searchQuery = normalized;
    notifyListeners();
  }

  void setSelectedFilter(String? filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> toggleFavourite(String cafeId) async {
    await _repository.toggleFavourite(cafeId);
    _cafes = await _repository.getCafes();
    notifyListeners();
  }
}
