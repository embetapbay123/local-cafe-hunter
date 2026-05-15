import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/models/cafe.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../shared/app_routes.dart';
import '../theme/cafe_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    context.read<CafeViewModel>().setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        if (_searchController.text != cafeViewModel.searchQuery) {
          _searchController.value = TextEditingValue(
            text: cafeViewModel.searchQuery,
            selection: TextSelection.collapsed(
              offset: cafeViewModel.searchQuery.length,
            ),
          );
        }

        if (cafeViewModel.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: CafeColors.dark),
            ),
          );
        }

        if (cafeViewModel.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: CafeColors.dark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Khong tai duoc du lieu quan cafe',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cafeViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: cafeViewModel.refresh,
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final pages = [
          _DiscoverPage(searchController: _searchController),
          _SearchPage(searchController: _searchController),
          const _ComingSoonPage(
            title: 'Saved list se toi o branch sau',
            subtitle:
                'Tam thoi ban van co the bam tim o Home hoac Search de danh dau nhanh cac quan can luu.',
            icon: Icons.favorite_rounded,
          ),
          _ProfilePreview(onSignedOut: _handleSignOut),
        ];

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD8C9B3), CafeColors.background],
              ),
            ),
            child: IndexedStack(
              index: cafeViewModel.selectedTabIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: cafeViewModel.selectedTabIndex,
            onDestinationSelected: cafeViewModel.setSelectedTabIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    await context.read<AuthViewModel>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final cafes = cafeViewModel.visibleCafes;
        final featured = cafes.take(3).toList();

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: CafeColors.dark,
            onRefresh: cafeViewModel.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
              children: [
                _PageHeading(
                  eyebrow: 'LOCAL CAFE HUNTER',
                  title: 'Chon quan nhanh, dung mood, de quay lai.',
                  subtitle:
                      'Home branch nay tap trung vao discover shell va danh sach cafe nen cho toan app.',
                  trailing: IconButton.filledTonal(
                    onPressed: () => _showFilters(context, cafeViewModel),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                _SearchBar(controller: searchController),
                const SizedBox(height: 18),
                _HeroCard(cafeCount: cafes.length),
                const SizedBox(height: 20),
                if (featured.isNotEmpty) ...[
                  const _SectionLabel(
                    title: 'Goi y nhanh',
                    subtitle: 'Nhung quan noi bat de mo dau luong kham pha',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final cafe = featured[index];
                        return _FeaturedCafeCard(
                          cafe: cafe,
                          onFavouriteToggle: () =>
                              cafeViewModel.toggleFavourite(cafe.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const _SectionLabel(
                  title: 'Danh sach de duyet nhanh',
                  subtitle:
                      'Menu, review va chi tiet se duoc mo rong o cac branch cafe tiep theo',
                ),
                const SizedBox(height: 12),
                if (cafes.isEmpty)
                  const _EmptyState(
                    title: 'Chua co ket qua phu hop',
                    subtitle: 'Thu bo filter hoac doi tu khoa tim kiem.',
                  )
                else
                  ...cafes.map(
                    (cafe) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CafeCard(
                        cafe: cafe,
                        onFavouriteToggle: () =>
                            cafeViewModel.toggleFavourite(cafe.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilters(BuildContext context, CafeViewModel cafeViewModel) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CafeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bo loc nhanh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: CafeColors.dark,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    selected: cafeViewModel.selectedFilter == null,
                    label: const Text('Tat ca'),
                    onSelected: (_) {
                      cafeViewModel.setSelectedFilter(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  ...cafeViewModel.availableFilters.map((filter) {
                    final selected = filter == cafeViewModel.selectedFilter;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(filter),
                      onSelected: (_) {
                        cafeViewModel.setSelectedFilter(filter);
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchPage extends StatelessWidget {
  const _SearchPage({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final cafes = cafeViewModel.visibleCafes;
        final activeFilter = cafeViewModel.selectedFilter;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            children: [
              _PageHeading(
                eyebrow: 'SEARCH FEATURE',
                title: 'Tim nhanh quan hop gu ngay tren mot man rieng.',
                subtitle:
                    'PR nay mo tab Search that su, con sort, radius va filter nang cao de lai cho branch search-advanced.',
                trailing: cafeViewModel.hasActiveSearch
                    ? IconButton.filledTonal(
                        onPressed: () {
                          searchController.clear();
                          cafeViewModel.clearSearch();
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
              const SizedBox(height: 18),
              _SearchBar(controller: searchController),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    selected: activeFilter == null,
                    label: const Text('Tat ca'),
                    onSelected: (_) => cafeViewModel.setSelectedFilter(null),
                  ),
                  ...cafeViewModel.availableFilters.map((filter) {
                    final selected = activeFilter == filter;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(filter),
                      onSelected: (_) => cafeViewModel.setSelectedFilter(
                        selected ? null : filter,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 18),
              _SearchSummaryCard(
                resultCount: cafes.length,
                query: cafeViewModel.searchQuery,
                filter: activeFilter,
              ),
              const SizedBox(height: 20),
              const _SectionLabel(
                title: 'Ket qua tim kiem',
                subtitle: 'Map va bo loc nang cao se duoc noi tiep sau branch nay',
              ),
              const SizedBox(height: 12),
              if (cafes.isEmpty)
                const _EmptyState(
                  title: 'Khong tim thay quan phu hop',
                  subtitle:
                      'Thu bo chip dang chon hoac nhap ten khu vuc, ten quan khac.',
                )
              else
                ...cafes.map(
                  (cafe) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CafeCard(
                      cafe: cafe,
                      onFavouriteToggle: () =>
                          cafeViewModel.toggleFavourite(cafe.id),
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

class _SearchSummaryCard extends StatelessWidget {
  const _SearchSummaryCard({
    required this.resultCount,
    required this.query,
    required this.filter,
  });

  final int resultCount;
  final String query;
  final String? filter;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.isNotEmpty;
    final hasFilter = filter != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CafeColors.dark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$resultCount ket qua dang san sang',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery || hasFilter
                ? 'Dang loc theo ${hasQuery ? '"$query"' : 'tat ca khu vuc'}${hasFilter ? ' va $filter' : ''}.'
                : 'Chua co bo loc nao duoc ap dung. Day la luong search co ban cua app.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({required this.onSignedOut});

  final Future<void> Function() onSignedOut;

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final profile = cafeViewModel.userProfile;
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PageHeading(
                  eyebrow: 'PROFILE PREVIEW',
                  title: 'Profile shell da san sang.',
                  subtitle:
                      'Thong tin chi tiet, collections va review history se duoc tach thanh branch rieng.',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CafeColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? 'Local Hunter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(profile?.email ?? 'supabase-user@local.dev'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatChip(
                            label: 'Saved',
                            value: '${cafeViewModel.favouriteCafes.length}',
                          ),
                          _StatChip(
                            label: 'Collections',
                            value: '${cafeViewModel.collections.length}',
                          ),
                          _StatChip(
                            label: 'Reviews',
                            value: '${cafeViewModel.reviewHistory.length}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: onSignedOut,
                        child: const Text('Dang xuat'),
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

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: CafeColors.dark),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                  color: CafeColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Tim theo ten quan, khu vuc...',
        filled: true,
        fillColor: CafeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.cafeCount});

  final int cafeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF654321), Color(0xFFB88543)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Home shell is live',
            style: TextStyle(
              color: Color(0xFFF7EEDF),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover feed nay la diem neo cho map, search va cafe detail o cac PR tiep theo.',
            style: TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(label: 'Loaded', value: '$cafeCount cafes'),
              const SizedBox(width: 10),
              const _StatChip(label: 'Status', value: 'Week 2'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _FeaturedCafeCard extends StatelessWidget {
  const _FeaturedCafeCard({
    required this.cafe,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(colors: cafe.gradientColors),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                  IconButton(
                    onPressed: onFavouriteToggle,
                    icon: Icon(
                      cafe.isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                cafe.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cafe.shortNote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFF6EBDD),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    cafe.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  const _CafeCard({
    required this.cafe,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CafeColors.dark.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: cafe.gradientColors),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cafe.name,
                  style: const TextStyle(
                    color: CafeColors.dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cafe.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CafeColors.muted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InlineChip(label: cafe.priceRange),
                    ...cafe.amenities
                        .take(2)
                        .map((amenity) => _InlineChip(label: amenity)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavouriteToggle,
            icon: Icon(
              cafe.isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: cafe.isFavourite ? CafeColors.heart : CafeColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CafeColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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

class _InlineChip extends StatelessWidget {
  const _InlineChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CafeColors.dark,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.coffee_outlined, size: 42, color: CafeColors.dark),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
