import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../models/collection.dart';
import '../models/menu_item.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class LocalCafeSeed {
  static const userProfile = UserProfile(
    userId: 'local-demo-user',
    displayName: 'Nguyen Thi Mieu',
    tagline: 'Ca phe khong chat, mat tinh anh em',
    level: 5,
    points: 200,
    email: 'conghotboy3@gmail.com',
    phone: '0123456789',
    avatarKey: 'cat-dev',
  );

  static const collections = [
    CafeCollection(
      id: 'collection-study',
      name: 'Quan hoc bai',
      cafeIds: ['ther-coffee', 'nang-som-coffee'],
    ),
    CafeCollection(
      id: 'collection-chill',
      name: 'Hen ban cuoi tuan',
      cafeIds: ['mieu-coffee', 'mer-cafe'],
    ),
  ];

  static final cafes = <Cafe>[
    Cafe(
      id: 'ther-coffee',
      name: 'Ther Coffee',
      address: '937 Ngo Quyen, Da Nang',
      description:
          'Khong gian am cung, nhieu goc ngoi thoang, mui ca phe ro va phu hop cho buoi hen nhe nhang.',
      shortNote: 'Khong gian am cung, ca phe thom, vua mieng :>',
      rating: 4.5,
      reviewCount: 12,
      priceRange: '30k - 65k',
      openingHours: '07:00 - 23:00',
      latitude: 16.0674,
      longitude: 108.2311,
      imageKey: 'street-cups',
      gradientColors: const [Color(0xFFAAD0D7), Color(0xFF6E8A95)],
      amenities: const ['Wifi manh', 'May lanh', 'Cho ngoai troi'],
      menu: const [
        MenuItem(
          id: 'ther-cappuccino',
          name: 'Cappuccino Signature',
          category: 'Coffee',
          price: 45000,
          imageKey: 'foam-cup',
          description: 'Vi sua mem, hat roasted dam mui.',
          isRecommended: true,
        ),
        MenuItem(
          id: 'ther-iced-americano',
          name: 'Iced Americano',
          category: 'Coffee',
          price: 40000,
          imageKey: 'iced-cup',
        ),
      ],
      reviews: [
        Review(
          id: 'ther-review-1',
          cafeId: 'ther-coffee',
          userId: 'local-demo-user',
          authorName: 'Mi Eu',
          rating: 4.5,
          comment: 'Quan rat dep, ca phe ngon, se quay lai.',
          createdAt: DateTime(2026, 4, 20),
          imageKey: 'review-corner',
        ),
      ],
      isFavourite: true,
    ),
    Cafe(
      id: 'nang-som-coffee',
      name: 'Nang Som Coffee',
      address: '112 Luong The Vinh, Da Nang',
      description:
          'Ban cong nhin duong dep, thuc uong de uong va rat hop cho buoi sang y yen.',
      shortNote: 'Tra dau ngon nen thu, gia ca phai chang <3',
      rating: 4.8,
      reviewCount: 30,
      priceRange: '28k - 70k',
      openingHours: '06:30 - 22:30',
      latitude: 16.0608,
      longitude: 108.2207,
      imageKey: 'morning-espresso',
      gradientColors: const [Color(0xFFB98A59), Color(0xFF5C3A1F)],
      amenities: const ['Wifi manh', 'Yen tinh', 'Cho cam sac'],
      menu: const [
        MenuItem(
          id: 'nang-som-espresso',
          name: 'Espresso Orange',
          category: 'Coffee',
          price: 49000,
          imageKey: 'orange-espresso',
          isRecommended: true,
        ),
      ],
      reviews: [
        Review(
          id: 'nang-review-1',
          cafeId: 'nang-som-coffee',
          userId: 'local-friend-2',
          authorName: 'Phuong',
          rating: 4.8,
          comment: 'View dep, nhac vua phai, rat hop de lam viec buoi sang.',
          createdAt: DateTime(2026, 3, 18),
          imageKey: 'review-window',
        ),
      ],
      isFavourite: true,
    ),
  ];
}
