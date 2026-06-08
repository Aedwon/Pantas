import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  var _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
    final syncStatus =
        ref.watch(syncStatusProvider).valueOrNull ?? const SyncIdle();
    final state = BackupViewState.fromSync(
      isAnonymous: isAnonymous,
      syncStatus: syncStatus,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(state.headline, style: styles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            state.subtitle,
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          if (state.actionLabel != null) ...[
            const SizedBox(height: 16),
            BoardButton(
              label: state.actionLabel!,
              secondary: true,
              onPressed: () => ref.read(syncEngineProvider).forceFlush(),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Text(
              _showDetails ? 'Hide details' : 'Show details',
              style: styles.labelLarge.copyWith(color: colors.board),
            ),
          ),
          if (_showDetails) ...[
            const SizedBox(height: 8),
            Text(
              'Last sync: ${state.details.lastSyncIso}\n'
              'Pending queue: ${state.details.pendingCount}\n'
              'Network: ${state.details.networkStatus}',
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
