import 'package:flutter/material.dart';

import 'menu_item.dart';
import 'review.dart';

enum CafeSource { localSeed, supabaseCatalog, overpass }

class Cafe {
  const Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.shortNote,
    required this.rating,
    required this.reviewCount,
    required this.priceRange,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
    required this.imageKey,
    required this.gradientColors,
    required this.amenities,
    required this.menu,
    required this.reviews,
    this.isFavourite = false,
    this.source = CafeSource.localSeed,
    this.osmId,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String address;
  final String description;
  final String shortNote;
  final double rating;
  final int reviewCount;
  final String priceRange;
  final String openingHours;
  final double latitude;
  final double longitude;
  final String imageKey;
  final List<Color> gradientColors;
  final List<String> amenities;
  final List<MenuItem> menu;
  final List<Review> reviews;
  final bool isFavourite;
  final CafeSource source;
  final String? osmId;
  final double? distanceMeters;

  Cafe copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    String? shortNote,
    double? rating,
    int? reviewCount,
    String? priceRange,
    String? openingHours,
    double? latitude,
    double? longitude,
    String? imageKey,
    List<Color>? gradientColors,
    List<String>? amenities,
    List<MenuItem>? menu,
    List<Review>? reviews,
    bool? isFavourite,
    CafeSource? source,
    String? osmId,
    double? distanceMeters,
  }) {
    return Cafe(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      shortNote: shortNote ?? this.shortNote,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceRange: priceRange ?? this.priceRange,
      openingHours: openingHours ?? this.openingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageKey: imageKey ?? this.imageKey,
      gradientColors: gradientColors ?? this.gradientColors,
      amenities: amenities ?? this.amenities,
      menu: menu ?? this.menu,
      reviews: reviews ?? this.reviews,
      isFavourite: isFavourite ?? this.isFavourite,
      source: source ?? this.source,
      osmId: osmId ?? this.osmId,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }
}
