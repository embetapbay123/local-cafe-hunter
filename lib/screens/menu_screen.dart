import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/data/mock_menu_data.dart';
import '../cafes/models/menu_item.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../theme/cafe_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    super.key,
    required this.cafeId,
  });

  final String cafeId;

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final cafe = cafeViewModel.getCafeById(cafeId);
        if (cafe == null) {
          return Scaffold(
            backgroundColor: CafeColors.background,
            appBar: AppBar(),
            body: const Center(
              child: Text('Khong tim thay menu cua quan nay.'),
            ),
          );
        }

        final menuItems = cafe.menu.isEmpty ? MockMenuData.fallbackMenu : cafe.menu;
        final groupedMenu = <String, List<MenuItem>>{};
        for (final item in menuItems) {
          groupedMenu.putIfAbsent(item.category, () => []).add(item);
        }

        return Scaffold(
          backgroundColor: CafeColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: cafe.gradientColors),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MENU FEATURE',
                              style: TextStyle(
                                color: Color(0xFFF7EEDF),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cafe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Danh sach mon duoc tach rieng khoi cafe detail de PR nay co scope ro rang.',
                              style: TextStyle(
                                color: Color(0xFFF7EEDF),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    children: [
                      _MenuSummaryCard(
                        totalItems: menuItems.length,
                        categoryCount: groupedMenu.length,
                        usesFallback: cafe.menu.isEmpty,
                      ),
                      const SizedBox(height: 16),
                      ...groupedMenu.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _MenuCategorySection(
                            category: entry.key,
                            items: entry.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuSummaryCard extends StatelessWidget {
  const _MenuSummaryCard({
    required this.totalItems,
    required this.categoryCount,
    required this.usesFallback,
  });

  final int totalItems;
  final int categoryCount;
  final bool usesFallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$totalItems mon trong $categoryCount nhom',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            usesFallback
                ? 'Quan nay chua co menu local day du, dang dung fallback menu de giu flow hoan chinh.'
                : 'Menu dang duoc lay truc tiep tu local cafe seed hien tai.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MenuCategorySection extends StatelessWidget {
  const _MenuCategorySection({
    required this.category,
    required this.items,
  });

  final String category;
  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MenuItemCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: CafeColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.category.toLowerCase() == 'bakery'
                  ? Icons.bakery_dining_rounded
                  : Icons.local_drink_rounded,
              color: CafeColors.dark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (item.isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: CafeColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Reco',
                          style: TextStyle(
                            color: CafeColors.dark,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description.isEmpty
                      ? 'Mon co ban trong nhom $categoryLabel'
                      : item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.price ~/ 1000}k',
            style: const TextStyle(
              color: CafeColors.dark,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String get categoryLabel => item.category.toLowerCase();
}
