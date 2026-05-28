import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/in_app_notification.dart';
import 'viewmodels/notification_center_viewmodel.dart';
import '../theme/cafe_theme.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCenterViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: CafeColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: CafeColors.dark,
            elevation: 0,
            title: const Text(
              'Thong bao',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                onPressed: viewModel.hasUnread
                    ? () => viewModel.markAllAsRead()
                    : null,
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Danh dau tat ca da doc',
              ),
              IconButton(
                onPressed: viewModel.clear,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Xoa toan bo',
              ),
            ],
          ),
          body: RefreshIndicator(
            color: CafeColors.dark,
            onRefresh: viewModel.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SummaryCard(
                  unreadCount: viewModel.unreadCount,
                  totalCount: viewModel.notifications.length,
                ),
                const SizedBox(height: 16),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: Center(
                      child: CircularProgressIndicator(color: CafeColors.dark),
                    ),
                  )
                else if (viewModel.notifications.isEmpty)
                  const _EmptyState()
                else
                  ...viewModel.notifications.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NotificationCard(
                        notification: notification,
                        onTap: notification.isUnread
                            ? () => viewModel.markAsRead(notification.id)
                            : null,
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.unreadCount,
    required this.totalCount,
  });

  final int unreadCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CafeColors.dark.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: CafeColors.accent.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.notifications_active_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unreadCount chua doc',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  totalCount == 0
                      ? 'Hop thu trong, se tu day len khi app dong bo catalog hoac co su kien moi.'
                      : 'Tong cong $totalCount thong bao duoc luu trong hop thu noi ung dung.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final InAppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: notification.isUnread
                ? CafeColors.surface
                : CafeColors.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: notification.isUnread
                  ? CafeColors.dark.withValues(alpha: 0.12)
                  : CafeColors.dark.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _categoryColor(notification.category),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _categoryIcon(notification.category),
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
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: CafeColors.heart,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _NotificationPill(
                          label: _categoryLabel(notification.category),
                        ),
                        Text(
                          _formatTime(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(InAppNotificationCategory category) {
    switch (category) {
      case InAppNotificationCategory.catalog:
        return const Color(0xFFE7D2A5);
      case InAppNotificationCategory.onboarding:
        return const Color(0xFFD8C9B3);
      case InAppNotificationCategory.preference:
        return const Color(0xFFE3CDBA);
      case InAppNotificationCategory.system:
        return const Color(0xFFF0E6D8);
    }
  }

  IconData _categoryIcon(InAppNotificationCategory category) {
    switch (category) {
      case InAppNotificationCategory.catalog:
        return Icons.storefront_rounded;
      case InAppNotificationCategory.onboarding:
        return Icons.rocket_launch_rounded;
      case InAppNotificationCategory.preference:
        return Icons.tune_rounded;
      case InAppNotificationCategory.system:
        return Icons.info_outline_rounded;
    }
  }

  String _categoryLabel(InAppNotificationCategory category) {
    switch (category) {
      case InAppNotificationCategory.catalog:
        return 'Catalog';
      case InAppNotificationCategory.onboarding:
        return 'Onboarding';
      case InAppNotificationCategory.preference:
        return 'Preference';
      case InAppNotificationCategory.system:
        return 'System';
    }
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} $hours:$minutes';
  }
}

class _NotificationPill extends StatelessWidget {
  const _NotificationPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CafeColors.dark,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 48),
          SizedBox(height: 12),
          Text(
            'Chua co thong bao nao',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CafeColors.dark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'App se day len catalog sync, onboarding va preference event vao day.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CafeColors.muted),
          ),
        ],
      ),
    );
  }
}
