import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../analytics/viewmodels/analytics_monitor_viewmodel.dart';
import '../notifications/viewmodels/notification_center_viewmodel.dart';
import '../shared/app_routes.dart';
import '../theme/cafe_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CafeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: CafeColors.dark,
        elevation: 0,
        title: const Text(
          'Cai dat',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Consumer<CafeViewModel>(
        builder: (context, cafeViewModel, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            children: [
              _SettingsSection(
                title: 'Hien thi',
                subtitle: 'Dieu chinh mat do card va cach app trinh bay noi dung.',
                children: [
                  SwitchListTile.adaptive(
                    value: cafeViewModel.compactCafeCards,
                    onChanged: (value) =>
                        unawaited(cafeViewModel.setCompactCafeCards(value)),
                    title: const Text('Compact cafe cards'),
                    subtitle: const Text(
                      'Rut gon card o Home, Search va Saved de xem duoc nhieu hon.',
                    ),
                    secondary: const Icon(Icons.view_day_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Map',
                subtitle: 'Bat hoac tat cac goi y phu tren man map explorer.',
                children: [
                  SwitchListTile.adaptive(
                    value: cafeViewModel.showMapHints,
                    onChanged: (value) =>
                        unawaited(cafeViewModel.setShowMapHints(value)),
                    title: const Text('Show map hints'),
                    subtitle: const Text(
                      'Hien ban kinh, sort mode va khoang cach noi bat tren map.',
                    ),
                    secondary: const Icon(Icons.map_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Analytics',
                subtitle:
                    'Xem event, screen view va error local de monitor nhanh tinh trang app.',
                children: [
                  Consumer<AnalyticsMonitorViewModel>(
                    builder: (context, analyticsViewModel, _) {
                      return ListTile(
                        leading: const Icon(Icons.query_stats_rounded),
                        title: const Text('Mo analytics monitor'),
                        subtitle: Text(
                          analyticsViewModel.errorCount == 0
                              ? 'Hien tai khong co error local.'
                              : '${analyticsViewModel.errorCount} error da duoc ghi lai.',
                        ),
                        onTap: () async {
                          await analyticsViewModel.recordAction(
                            'open_analytics_monitor',
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed(
                            AppRoutes.analytics,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Thong bao',
                subtitle:
                    'Hop thu noi ung dung luu cac su kien sync, onboarding va preference.',
                children: [
                  Consumer<NotificationCenterViewModel>(
                    builder: (context, notificationViewModel, _) {
                      return ListTile(
                        leading: const Icon(Icons.notifications_none_rounded),
                        title: const Text('Mo hop thu thong bao'),
                        subtitle: Text(
                          notificationViewModel.unreadCount == 0
                              ? 'Khong co thong bao chua doc.'
                              : '${notificationViewModel.unreadCount} thong bao chua doc.',
                        ),
                        onTap: () async {
                          await context
                              .read<AnalyticsMonitorViewModel>()
                              .recordAction(
                            'open_notification_center',
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed(
                            AppRoutes.notifications,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Session',
                subtitle: 'Xoa tro ve mac dinh hoac dang xuat khoi app.',
                children: [
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: const Text('Khoi phuc mac dinh'),
                    subtitle: const Text(
                      'Reset tat ca preference ve trang thai ban dau.',
                    ),
                    onTap: () async {
                      await cafeViewModel.resetSettings();
                      await context
                          .read<NotificationCenterViewModel>()
                          .recordPreferenceEvent(
                            title: 'Da khoi phuc cau hinh mac dinh',
                            body:
                                'Tat ca preference local va map hints da duoc reset.',
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Da khoi phuc cau hinh mac dinh.'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: CafeColors.heart,
                    ),
                    title: const Text('Dang xuat'),
                    subtitle: const Text('Quay ve man login cua app.'),
                    onTap: () async {
                      await context.read<AuthViewModel>().signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 2),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
