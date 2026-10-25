import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _backUp() async {
    if (_busy) return;
    final runtime = ref.read(syncRuntimeProvider);
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await runtime.forceFlush();
    } catch (_) {
      if (mounted && uid == ref.read(currentUserProvider).valueOrNull?.uid) {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(syncStatusProvider).valueOrNull;
    final anonymous = ref.watch(isAnonymousProvider).valueOrNull ?? true;
    final pro =
        ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
    final runtime = ref.watch(syncRuntimeProvider);
    final offline = status is SyncOffline;
    final busy = _busy || status is Syncing || status is SyncActivating;
    final failed = _failed ||
        status is SyncError ||
        status is SyncPartialFailure ||
        status is SyncFailedSince;
    final value = busy
        ? 'Backing up'
        : offline
            ? 'Offline'
            : failed
                ? "Couldn't back up"
                : switch (status) {
                    SyncUpToDate() || SyncOk() => 'Saved',
                    _ => 'Not backed up',
                  };
    final last = switch (status) {
      SyncUpToDate(:final lastSyncedAt) => lastSyncedAt,
      SyncOk(:final lastSyncedAt) => lastSyncedAt,
      SyncIdle(:final lastSyncedAt) => lastSyncedAt,
      _ => null,
    };
    final pending = switch (status) {
      Syncing(:final pendingCount) ||
      SyncOffline(:final pendingCount) ||
      SyncOk(:final pendingCount) =>
        pendingCount,
      _ => null,
    };
    final canFlush = !anonymous &&
        pro &&
        !offline &&
        !busy &&
        runtime.runtimeKind == SyncRuntimeKind.configured;
    return PantasPage(
      title: 'Backup',
      backLabel: 'Account',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        GroupedSection(
          header: 'Backup',
          footer: busy
              ? 'This takes a moment. You can keep using Pantas.'
              : offline
                  ? "It backs up when you're back online."
                  : failed
                      ? 'Your progress is safe on this phone.'
                      : "Pantas backs up on its own whenever you're online.",
          children: [
            ListRow(
              title: 'Backup',
              value: value,
              variant: ListRowVariant.value,
              divider: true,
              trailingWidget: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            if (last != null)
              ListRow(
                title: 'Last backed up',
                value: '${DateFormat.yMMMd().format(last.toLocal())}, '
                    '${DateFormat.jm().format(last.toLocal())}',
                variant: ListRowVariant.value,
                divider: pending != null,
              ),
            if (pending != null)
              ListRow(
                title: 'Waiting to back up',
                value: pending == 0
                    ? 'Nothing'
                    : '$pending ${pending == 1 ? 'change' : 'changes'}',
                variant: ListRowVariant.value,
              ),
          ],
        ),
        const SizedBox(height: 24),
        PantasButton(
          label: failed ? 'Try Again' : 'Back Up Now',
          busy: busy,
          onPressed: canFlush ? _backUp : null,
        ),
        if (offline)
          Text(
            'You need a connection to back up.',
            style: context.type.footnote,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
