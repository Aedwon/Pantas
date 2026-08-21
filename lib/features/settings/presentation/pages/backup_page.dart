import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Backup', backLabel: 'Settings'),
          const SizedBox(height: 16),
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
