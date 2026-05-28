import 'package:flutter/material.dart';

import '../data/local_cafe_seed.dart';
import '../models/cafe.dart';
import '../models/cafe_catalog_sync_report.dart';
import '../models/menu_item.dart';
import '../models/review.dart';
import '../../services/supabase_service.dart';

class CafeCatalogSyncService {
  const CafeCatalogSyncService();

  Future<CafeCatalogSyncReport> syncCatalog() async {
    final client = SupabaseService.client;
    if (client == null) {
      return _fallbackReport(
        'Supabase is not configured, using the bundled local cafe seed.',
      );
    }

    try {
      final rows = await client.from('cafe_catalog').select();
      final cafes = _parseCatalogRows(rows);
      if (cafes.isEmpty) {
        return _fallbackReport(
          'Supabase cafe_catalog is empty, using the bundled local cafe seed.',
        );
      }

      return CafeCatalogSyncReport(
        cafes: cafes,
        source: CafeSource.supabaseCatalog,
        usedFallback: false,
        syncedAt: DateTime.now(),
        message: 'Loaded ${cafes.length} cafes from Supabase catalog.',
      );
    } catch (error) {
      return _fallbackReport(
        'Supabase cafe_catalog sync failed, using the bundled local cafe seed.',
        details: error.toString(),
      );
    }
  }

  CafeCatalogSyncReport _fallbackReport(
    String message, {
    String? details,
  }) {
    return CafeCatalogSyncReport(
      cafes: List<Cafe>.from(LocalCafeSeed.cafes),
      source: CafeSource.localSeed,
      usedFallback: true,
      syncedAt: DateTime.now(),
      message: details == null ? message : '$message Details: $details',
    );
  }

  List<Cafe> _parseCatalogRows(dynamic rows) {
    if (rows is! List) return const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_parseCafeRow)
        .whereType<Cafe>()
        .toList();
  }

  Cafe? _parseCafeRow(Map<String, dynamic> row) {
    final payload = row['payload'];
    final data = payload is Map<String, dynamic> ? payload : row;

    final id = _readString(data, 'id');
    final name = _readString(data, 'name');
    final address = _readString(data, 'address');
    final description = _readString(data, 'description');
    final shortNote = _readString(data, 'short_note', fallback: 'Cafe local dang duoc dong bo.');
    final priceRange = _readString(data, 'price_range');
    final openingHours = _readString(data, 'opening_hours');
    final imageKey = _readString(data, 'image_key');
    final rating = _readDouble(data, 'rating');
    final reviewCount = _readInt(data, 'review_count');
    final latitude = _readDouble(data, 'latitude');
    final longitude = _readDouble(data, 'longitude');
    final gradientStart = _readColor(data, 'gradient_start');
    final gradientEnd = _readColor(data, 'gradient_end');
    final amenities = _readStringList(data, 'amenities');

    if (id.isEmpty ||
        name.isEmpty ||
        address.isEmpty ||
        description.isEmpty ||
        priceRange.isEmpty ||
        openingHours.isEmpty ||
        imageKey.isEmpty ||
        rating == null ||
        reviewCount == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }

    return Cafe(
      id: id,
      name: name,
      address: address,
      description: description,
      shortNote: shortNote,
      rating: rating,
      reviewCount: reviewCount,
      priceRange: priceRange,
      openingHours: openingHours,
      latitude: latitude,
      longitude: longitude,
      imageKey: imageKey,
      gradientColors: [gradientStart, gradientEnd],
      amenities: amenities,
      menu: const <MenuItem>[],
      reviews: const <Review>[],
      source: CafeSource.supabaseCatalog,
      osmId: _readString(data, 'osm_id', allowEmpty: true),
    );
  }

  String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
    bool allowEmpty = false,
  }) {
    final value = data[key];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty || allowEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }

  double? _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  int? _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  List<String> _readStringList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List) {
      return value
          .whereType<Object?>()
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  Color _readColor(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return Color(value);
    }
    if (value is String) {
      final normalized = value
          .trim()
          .replaceFirst('#', '')
          .replaceFirst('0x', '');
      if (normalized.isNotEmpty) {
        final padded = normalized.length == 6 ? 'FF$normalized' : normalized;
        final parsed = int.tryParse(padded, radix: 16);
        if (parsed != null) {
          return Color(parsed);
        }
      }
    }
    return const Color(0xFFB9A48E);
  }
}
