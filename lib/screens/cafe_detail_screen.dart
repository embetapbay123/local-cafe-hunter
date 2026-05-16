import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/models/cafe.dart';
import '../cafes/models/menu_item.dart';
import '../cafes/models/review.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../theme/cafe_theme.dart';

class CafeDetailScreen extends StatelessWidget {
  const CafeDetailScreen({
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
              child: Text('Khong tim thay quan cafe can xem chi tiet.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: CafeColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: CafeColors.background,
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroBanner(
                    cafe: cafe,
                    onFavouriteToggle: () =>
                        cafeViewModel.toggleFavourite(cafe.id),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeadlineBlock(cafe: cafe),
                      const SizedBox(height: 18),
                      _StatRail(cafe: cafe),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Cau chuyen cua quan',
                        child: Text(
                          cafe.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Tien ich noi bat',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: cafe.amenities
                              .map((amenity) => _AmenityChip(label: amenity))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Menu preview',
                        subtitle:
                            'Branch menu-feature se mo rong toan bo menu va nhom mon.',
                        child: Column(
                          children: cafe.menu
                              .take(2)
                              .map((item) => _MenuPreviewTile(item: item))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Review preview',
                        subtitle:
                            'Branch review-feature se bo sung feed review day du va thao tac gui review.',
                        child: Column(
                          children: cafe.reviews
                              .take(2)
                              .map((review) => _ReviewPreviewTile(review: review))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Huong phat trien branch',
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BranchNote(text: 'Menu day du se toi o menu-feature.'),
                            _BranchNote(
                              text: 'Review list va review submission se toi o review-feature.',
                            ),
                            _BranchNote(
                              text: 'Saved va collections van duoc tach sang cac branch sau.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.cafe,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 72, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cafe.gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cafe.priceRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: onFavouriteToggle,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                icon: Icon(
                  cafe.isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            cafe.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            cafe.shortNote,
            style: const TextStyle(
              color: Color(0xFFF7EEDF),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock({required this.cafe});

  final Cafe cafe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAFE DETAIL',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
            color: CafeColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cafe.address,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Mo cua ${cafe.openingHours} . Nguon du lieu hien tai la local seed de chuan bi cho cac flow sau.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _StatRail extends StatelessWidget {
  const _StatRail({required this.cafe});

  final Cafe cafe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatPill(
          label: 'Rating',
          value: cafe.rating.toStringAsFixed(1),
        ),
        _StatPill(
          label: 'Reviews',
          value: '${cafe.reviewCount}',
        ),
        _StatPill(
          label: 'Khoang cach',
          value: cafe.distanceMeters == null
              ? 'Local seed'
              : cafe.distanceMeters! >= 1000
                  ? '${(cafe.distanceMeters! / 1000).toStringAsFixed(1)} km'
                  : '${cafe.distanceMeters!.round()} m',
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CafeColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: CafeColors.dark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CafeColors.dark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MenuPreviewTile extends StatelessWidget {
  const _MenuPreviewTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: CafeColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_drink_rounded, color: CafeColors.dark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  item.description.isEmpty ? item.category : item.description,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPreviewTile extends StatelessWidget {
  const _ReviewPreviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: CafeColors.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _BranchNote extends StatelessWidget {
  const _BranchNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.coffee_rounded,
              size: 14,
              color: CafeColors.dark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
