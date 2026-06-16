import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          if (user == null && isAnonymous) ...[
            Text(
              'Your progress is saved on this device. Sign in to back it up '
              'and use it on other devices.',
              style: context.textStyles.bodyMedium
                  .copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 16),
            BoardButton(
              label: 'Sign in with Google',
              onPressed: () =>
                  ref.read(authRepositoryProvider).signInWithGoogle(),
            ),
            const SizedBox(height: 24),
            SettingsRow(
              title: 'Delete my data',
              onTap: () => _go(context, '/settings/account/delete'),
            ),
          ] else ...[
            Text(
              user?.displayName.isNotEmpty ?? false
                  ? user!.displayName
                  : 'Account',
              style: context.textStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 24),
            SettingsRow(
              title: 'Sign out',
              subtitle: _pendingSyncCopy(syncStatus),
              onTap: () => _confirmSignOut(context, ref),
            ),
            SettingsRow(
              title: 'Delete account',
              destructive: true,
              onTap: () => _go(context, '/settings/account/delete'),
            ),
          ],
        ],
      ),
    );
  }

  static String? _pendingSyncCopy(SyncStatus? status) {
    final pending = switch (status) {
      Syncing(:final pendingCount) => pendingCount,
      SyncOk(:final pendingCount) => pendingCount,
      _ => 0,
    };
    if (pending <= 0) return null;
    return 'You have $pending items not yet backed up.';
  }

  static Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your study progress on this device will be cleared. You can sign '
          'back in to restore it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  static void _go(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    // Push, never go: these destinations sit outside the tab shell and rely
    // on the AppBar's implicit back arrow, which only appears when the
    // stack can pop.
    if (router != null) unawaited(router.push<void>(location));
  }
}
