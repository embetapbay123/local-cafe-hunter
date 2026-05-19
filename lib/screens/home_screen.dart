import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/models/cafe.dart';
import '../cafes/models/collection.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../screens/cafe_detail_screen.dart';
import '../screens/map_screen.dart';
import '../shared/app_routes.dart';
import '../theme/cafe_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

void _openCafeDetailScreen(BuildContext context, String cafeId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CafeDetailScreen(cafeId: cafeId),
    ),
  );
}

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
          const _SavedPage(),
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
                          onOpenDetail: () =>
                              _openCafeDetailScreen(context, cafe.id),
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
                        onOpenDetail: () =>
                            _openCafeDetailScreen(context, cafe.id),
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
                eyebrow: 'SEARCH + MAP',
                title: 'Tim nhanh quan hop gu ngay tren mot man rieng.',
                subtitle:
                    'Search da live va map explorer co the mo truc tiep tu day. Sort, radius va filter nang cao van de lai cho branch search-advanced.',
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
              const SizedBox(height: 16),
              _MapLaunchCard(
                nearbyCount: cafeViewModel.nearbyCafes.length,
                onOpenMap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const _SectionLabel(
                title: 'Ket qua tim kiem',
                subtitle: 'Map explorer da co, bo loc nang cao se duoc noi tiep sau branch nay',
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
                      onOpenDetail: () =>
                          _openCafeDetailScreen(context, cafe.id),
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

class _SavedPage extends StatelessWidget {
  const _SavedPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final savedCafes = cafeViewModel.favouriteCafes;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            children: [
              const _PageHeading(
                eyebrow: 'SAVED CAFES',
                title: 'Danh sach quan da luu da san sang.',
                subtitle:
                    'Branch nay tap trung vao saved list de truy cap nhanh cac quan yeu thich.',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: CafeColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: CafeColors.dark.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: CafeColors.heart,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${savedCafes.length} quan da duoc danh dau luu.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _SectionLabel(
                title: 'Truy cap nhanh',
                subtitle: 'Mo chi tiet hoac bo luu truc tiep tu danh sach nay',
              ),
              const SizedBox(height: 12),
              if (savedCafes.isEmpty)
                const _EmptyState(
                  title: 'Ban chua luu quan nao',
                  subtitle:
                      'Bam tim o Home, Search, hoac Detail de dua quan vao danh sach Saved.',
                )
              else
                ...savedCafes.map(
                  (cafe) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CafeCard(
                      cafe: cafe,
                      onOpenDetail: () => _openCafeDetailScreen(context, cafe.id),
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

class _MapLaunchCard extends StatelessWidget {
  const _MapLaunchCard({
    required this.nearbyCount,
    required this.onOpenMap,
  });

  final int nearbyCount;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E2218), Color(0xFF8A633C)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MAP EXPLORER',
                  style: TextStyle(
                    color: Color(0xFFF6EBDD),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mo ban do gia lap tu toa do cafe hien co, tap trung vao cac diem gan nhat.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$nearbyCount diem dang san sang cho luong map.',
                  style: const TextStyle(
                    color: Color(0xFFF7EEDF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          FilledButton(
            onPressed: onOpenMap,
            style: FilledButton.styleFrom(
              backgroundColor: CafeColors.surface,
              foregroundColor: CafeColors.dark,
              minimumSize: const Size(0, 54),
            ),
            child: const Text('Mo map'),
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
                      'Collections da co danh sach de mo nhanh. Profile chi tiet va review history se tiep tuc mo rong o branch sau.',
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
                const SizedBox(height: 18),
                const _SectionLabel(
                  title: 'Collections',
                  subtitle: 'Tap hop quan theo muc dich de mo chi tiet nhanh',
                ),
                const SizedBox(height: 12),
                if (cafeViewModel.collections.isEmpty)
                  const _EmptyState(
                    title: 'Chua co collection nao',
                    subtitle: 'Ban co the tao va quan ly collection o branch tiep theo.',
                  )
                else
                  ...cafeViewModel.collections.map(
                    (collection) {
                      final cafesInCollection = collection.cafeIds
                          .map(cafeViewModel.getCafeById)
                          .whereType<Cafe>()
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CollectionCard(
                          collection: collection,
                          cafes: cafesInCollection,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.cafes,
  });

  final CafeCollection collection;
  final List<Cafe> cafes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CafeColors.dark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collection.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${cafes.length} quan',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (cafes.isEmpty)
            const Text('Collection nay chua co quan nao.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cafes.map((cafe) {
                return ActionChip(
                  label: Text(cafe.name),
                  onPressed: () => _openCafeDetailScreen(context, cafe.id),
                );
              }).toList(),
            ),
        ],
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
    required this.onOpenDetail,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onOpenDetail;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(26),
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
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  const _CafeCard({
    required this.cafe,
    required this.onOpenDetail,
    required this.onFavouriteToggle,
  });

  final Cafe cafe;
  final VoidCallback onOpenDetail;
  final VoidCallback onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
