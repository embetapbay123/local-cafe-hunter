import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
