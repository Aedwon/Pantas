import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';

/// What the web build tells a student without Pro about where progress lives.
const webFreeBackupNote = 'Your browser saves data on this device. Pantas also '
    'keeps answers and study activity on its servers, including on Free. '
    'Pro adds backup and syncing across your devices.';

/// The one line the Backup row shows, on this page and on Account.
String backupLabel(
  SyncStatus? status, {
  required DateTime now,
  bool busy = false,
  bool failed = false,
}) {
  if (busy || status is Syncing || status is SyncActivating) {
    return 'Backing up';
  }
  if (status is SyncOffline) return 'Offline';
  if (failed ||
      status is SyncError ||
      status is SyncPartialFailure ||
      status is SyncFailedSince) {
    return "Couldn't back up";
  }
  final last = switch (status) {
    SyncUpToDate(:final lastSyncedAt) => lastSyncedAt,
    SyncOk(:final lastSyncedAt) => lastSyncedAt,
    _ => null,
  };
  if (status is! SyncUpToDate && status is! SyncOk) return 'Not backed up';
  if (last == null) return 'Saved';
  final at = last.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final time = DateFormat.jm().format(at);
  if (day == today) return 'Saved today, $time';
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Saved yesterday, $time';
  }
  return 'Saved ${DateFormat.MMMd().format(at)}, $time';
}

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
    final telemetry = ref.read(telemetryProvider);
    try {
      await runtime.forceFlush();
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted && uid == ref.read(currentUserProvider).valueOrNull?.uid) {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = ref.watch(paymentsOnWebProvider);
    // Web without Pro has no backup to show, and the browser alone does not
    // hold everything: answers also reach the server, on Free too.
    final saved = !(ref.watch(isAnonymousProvider).valueOrNull ?? true) &&
        (ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false);
    if (web && !saved) {
      return SettingsPanePage(
        section: 'Account',
        title: 'Backup',
        backLabel: 'Account',
        onBack: () => leavePage(context, fallback: '/settings/account'),
        children: const [Text(webFreeBackupNote)],
      );
    }
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
    final value = backupLabel(
      status,
      busy: _busy,
      failed: _failed,
      now: DateTime.now(),
    );
    final canFlush = !anonymous &&
        pro &&
        !offline &&
        !busy &&
        runtime.runtimeKind == SyncRuntimeKind.configured;
    // One row and one footer in every state, so nothing moves while the
    // status changes (Aedwon, Nov 8: the page jumped while backing up).
    return SettingsPanePage(
      section: 'Account',
      title: 'Backup',
      backLabel: 'Account',
      onBack: () => leavePage(context, fallback: '/settings/account'),
      children: [
        SettingsSection(
          header: 'Backup',
          footer: "Pantas backs up on its own whenever you're online.",
          children: [
            SettingsRow(
              title: 'Backup',
              value: value,
              variant: ListRowVariant.value,
              trailingWidget: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // The hidden copy is the widest the button gets (spinner and label),
        // so the button keeps one width in every state.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Stack(
            children: [
              const ExcludeSemantics(
                child: IgnorePointer(
                  child: TickerMode(
                    // A still spinner sizes the guide without animating.
                    enabled: false,
                    child: Opacity(
                      opacity: 0,
                      child: PantasButton(label: 'Back Up Now', busy: true),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: PantasButton(
                  label: failed ? 'Try Again' : 'Back Up Now',
                  busy: busy,
                  onPressed: canFlush ? _backUp : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
