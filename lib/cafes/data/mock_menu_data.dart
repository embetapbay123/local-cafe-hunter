import '../models/menu_item.dart';

class MockMenuData {
  static const fallbackMenu = <MenuItem>[
    MenuItem(
      id: 'fallback-espresso',
      name: 'Espresso',
      category: 'Coffee',
      price: 35000,
      imageKey: 'espresso-basic',
      description: 'Shot dam vi cho buoi sang tinh tao.',
    ),
    MenuItem(
      id: 'fallback-latte',
      name: 'Latte',
      category: 'Coffee',
      price: 45000,
      imageKey: 'latte-basic',
      description: 'Vi mem, de uong, phu hop moi thoi diem.',
    ),
    MenuItem(
      id: 'fallback-croissant',
      name: 'Croissant',
      category: 'Bakery',
      price: 32000,
      imageKey: 'croissant-basic',
      description: 'Banh bo nhe, hop voi coffee nong.',
    ),
  ];
}
