import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/models/cafe.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../screens/cafe_detail_screen.dart';
import '../theme/cafe_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final cafes = cafeViewModel.nearbyCafes;

        return Scaffold(
          backgroundColor: CafeColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MAP EXPLORER',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w900,
                                color: CafeColors.muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mo phong luong kham pha cafe theo vi tri.',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: cafeViewModel.refreshNearbyCafes,
                        icon: const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: _MapCanvas(
                          cafes: cafes,
                          highlightedCafe:
                              cafeViewModel.highlightedNearbyCafe,
                          onMarkerPressed: (cafe) {
                            _openCafeDetail(context, cafe.id);
                          },
                        ),
                      ),
                      if (cafeViewModel.isMapLoading)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0x14000000),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: CafeColors.dark,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: CafeColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${cafes.length} diem gan tam hien tai',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (cafeViewModel.highlightedNearbyCafe case final cafe?)
                              _DistanceBadge(
                                distanceMeters: cafe.distanceMeters,
                              ),
                          ],
                        ),
                      ),
                      if (cafeViewModel.mapErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Text(
                            cafeViewModel.mapErrorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      SizedBox(
                        height: 236,
                        child: cafes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: _MapEmptyState(),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: cafes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final cafe = cafes[index];
                                  return _MapCafeCard(
                                    cafe: cafe,
                                    onFocus: () {
                                      cafeViewModel.setMapFocus(
                                        latitude: cafe.latitude,
                                        longitude: cafe.longitude,
                                      );
                                    },
                                    onOpenDetail: () =>
                                        _openCafeDetail(context, cafe.id),
                                    onFavouriteToggle: () => cafeViewModel
                                        .toggleFavourite(cafe.id),
                                  );
                                },
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

  void _openCafeDetail(BuildContext context, String cafeId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CafeDetailScreen(cafeId: cafeId),
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.cafes,
    required this.highlightedCafe,
    required this.onMarkerPressed,
  });

  final List<Cafe> cafes;
  final Cafe? highlightedCafe;
  final ValueChanged<Cafe> onMarkerPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final positions = _buildMarkerLayout(
          cafes: cafes,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A2C22), Color(0xFFB78851), Color(0xFFE8D2AE)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _MapBackdropPattern()),
              ...positions.map((entry) {
                final isHighlighted = highlightedCafe?.id == entry.cafe.id;
                return Positioned(
                  left: entry.dx,
                  top: entry.dy,
                  child: GestureDetector(
                    onTap: () => onMarkerPressed(entry.cafe),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? CafeColors.accent
                            : CafeColors.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: CafeColors.dark.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: isHighlighted
                                ? CafeColors.dark
                                : CafeColors.heart,
                            size: isHighlighted ? 26 : 24,
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 74,
                            child: Text(
                              entry.cafe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CafeColors.dark,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<_MarkerLayout> _buildMarkerLayout({
    required List<Cafe> cafes,
    required double width,
    required double height,
  }) {
    if (cafes.isEmpty) {
      return const [];
    }

    final minLatitude =
        cafes.map((cafe) => cafe.latitude).reduce(math.min);
    final maxLatitude =
        cafes.map((cafe) => cafe.latitude).reduce(math.max);
    final minLongitude =
        cafes.map((cafe) => cafe.longitude).reduce(math.min);
    final maxLongitude =
        cafes.map((cafe) => cafe.longitude).reduce(math.max);

    const cardWidth = 86.0;
    const cardHeight = 76.0;
    const horizontalPadding = 14.0;
    const verticalPadding = 18.0;

    return cafes.map((cafe) {
      final latitudeSpan = maxLatitude - minLatitude;
      final longitudeSpan = maxLongitude - minLongitude;
      final normalizedX = longitudeSpan == 0
          ? 0.5
          : (cafe.longitude - minLongitude) / longitudeSpan;
      final normalizedY = latitudeSpan == 0
          ? 0.5
          : (maxLatitude - cafe.latitude) / latitudeSpan;

      final dx = horizontalPadding +
          normalizedX * (width - cardWidth - horizontalPadding * 2);
      final dy = verticalPadding +
          normalizedY * (height - cardHeight - verticalPadding * 2);

      return _MarkerLayout(cafe: cafe, dx: dx, dy: dy);
    }).toList();
  }
}

class _MapBackdropPattern extends StatelessWidget {
  const _MapBackdropPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapBackdropPainter(),
    );
  }
}

class _MapBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i < 6; i++) {
      final dx = size.width * i / 6;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    for (var i = 1; i < 5; i++) {
      final dy = size.height * i / 5;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final scenicPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.46,
        size.width * 0.38,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.64,
        size.width * 0.67,
        size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.79,
        size.height * 0.10,
        size.width * 0.92,
        size.height * 0.22,
      );

    canvas.drawPath(scenicPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapCafeCard extends StatelessWidget {
  const _MapCafeCard({
    required this.cafe,
    required this.onFocus,
    required this.onOpenDetail,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onFocus;
  final VoidCallback onOpenDetail;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CafeColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cafe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onFavouriteToggle,
                  icon: Icon(
                    cafe.isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color:
                        cafe.isFavourite ? CafeColors.heart : CafeColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              cafe.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DistanceBadge(distanceMeters: cafe.distanceMeters),
                _CompactChip(label: cafe.priceRange),
              ],
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: onOpenDetail,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Mo chi tiet'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onFocus,
              child: const Text('Doi tam map ve day'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48, color: CafeColors.dark),
              SizedBox(height: 12),
              Text(
                'Khong co diem map phu hop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CafeColors.dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.distanceMeters});

  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final label = distanceMeters == null
        ? 'Khoang cach chua ro'
        : distanceMeters! >= 1000
            ? '${(distanceMeters! / 1000).toStringAsFixed(1)} km'
            : '${distanceMeters!.round()} m';

    return _CompactChip(label: label);
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: CafeColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CafeColors.dark,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MarkerLayout {
  const _MarkerLayout({
    required this.cafe,
    required this.dx,
    required this.dy,
  });

  final Cafe cafe;
  final double dx;
  final double dy;
}
