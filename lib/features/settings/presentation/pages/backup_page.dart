import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;

    final lastSyncedAt = switch (syncStatus) {
      SyncOk(:final lastSyncedAt) => lastSyncedAt,
      SyncIdle(:final lastSyncedAt) => lastSyncedAt,
      _ => null,
    };

    final String backupValue;
    if (lastSyncedAt != null) {
      final d = lastSyncedAt.toLocal();
      final year = d.year;
      final month = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      backupValue = 'Last backed up $year-$month-$day';
    } else {
      backupValue = 'Not backed up yet';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            backupValue,
            style: styles.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your progress is automatically saved when connected.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
