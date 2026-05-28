import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/analytics_event.dart';
import 'viewmodels/analytics_monitor_viewmodel.dart';
import '../theme/cafe_theme.dart';

class AnalyticsMonitorScreen extends StatefulWidget {
  const AnalyticsMonitorScreen({super.key});

  @override
  State<AnalyticsMonitorScreen> createState() => _AnalyticsMonitorScreenState();
}

class _AnalyticsMonitorScreenState extends State<AnalyticsMonitorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsMonitorViewModel>().recordScreenView(
            'analytics_monitor',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsMonitorViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: CafeColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: CafeColors.dark,
            elevation: 0,
            title: const Text(
              'Analytics',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                onPressed: viewModel.clear,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Xoa log',
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
                  totalEvents: viewModel.totalEvents,
                  errorCount: viewModel.errorCount,
                  actionCount: viewModel.actionCount,
                  screenCount: viewModel.screenCount,
                ),
                const SizedBox(height: 16),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: Center(
                      child: CircularProgressIndicator(color: CafeColors.dark),
                    ),
                  )
                else if (viewModel.events.isEmpty)
                  const _EmptyState()
                else
                  ...viewModel.events.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EventCard(event: event),
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
    required this.totalEvents,
    required this.errorCount,
    required this.actionCount,
    required this.screenCount,
  });

  final int totalEvents;
  final int errorCount;
  final int actionCount;
  final int screenCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CafeColors.dark.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatPill(label: 'Events', value: '$totalEvents'),
          _StatPill(label: 'Errors', value: '$errorCount'),
          _StatPill(label: 'Actions', value: '$actionCount'),
          _StatPill(label: 'Screens', value: '$screenCount'),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: CafeColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final AnalyticsEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: event.isError
              ? CafeColors.heart.withValues(alpha: 0.28)
              : CafeColors.dark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeChip(type: event.type),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                _formatTime(event.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (event.details.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.details.entries
                  .map(
                    (entry) => _DetailChip(
                      label: '${entry.key}: ${entry.value}',
                    ),
                  )
                  .toList(),
            ),
          ],
          if (event.isError) ...[
            const SizedBox(height: 10),
            Text(
              'severity: ${event.severity}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month} $hours:$minutes';
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final AnalyticsEventType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      AnalyticsEventType.app => 'App',
      AnalyticsEventType.screen => 'Screen',
      AnalyticsEventType.action => 'Action',
      AnalyticsEventType.error => 'Error',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CafeColors.dark,
          fontWeight: FontWeight.w700,
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
          Icon(Icons.query_stats_rounded, size: 48),
          SizedBox(height: 12),
          Text(
            'Chua co analytics event',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CafeColors.dark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'App se day len screen, action va error event khi nguoi dung thao tac.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CafeColors.muted),
          ),
        ],
      ),
    );
  }
}
