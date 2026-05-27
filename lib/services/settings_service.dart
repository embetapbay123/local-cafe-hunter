import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _compactCafeCardsKey = 'local_cafe_hunter.settings.compact_cards';
  static const _showMapHintsKey = 'local_cafe_hunter.settings.show_map_hints';

  Future<bool> getCompactCafeCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_compactCafeCardsKey) ?? false;
  }

  Future<bool> getShowMapHints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showMapHintsKey) ?? true;
  }

  Future<void> setCompactCafeCards(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_compactCafeCardsKey, value);
  }

  Future<void> setShowMapHints(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showMapHintsKey, value);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_compactCafeCardsKey);
    await prefs.remove(_showMapHintsKey);
  }
}
