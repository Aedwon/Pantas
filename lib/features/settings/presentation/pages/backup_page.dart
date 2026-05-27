import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          Text(state.headline,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(state.subtitle),
          if (state.actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.read(syncEngineProvider).forceFlush(),
              child: Text(state.actionLabel!),
            ),
          ],
          TextButton(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            child: Text(_showDetails ? 'Hide details' : 'Show details'),
          ),
          if (_showDetails) ...[
            Text('Last sync: ${state.details.lastSyncIso}'),
            Text('Pending queue: ${state.details.pendingCount}'),
            Text('Network: ${state.details.networkStatus}'),
          ],
        ],
      ),
    );
  }
}
