import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/auth/sign_in_result.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;

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
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: context.textStyles.bodySmall
                    .copyWith(color: context.colors.rust),
              ),
              const SizedBox(height: 12),
            ],
            BoardButton(
              label: 'Sign in with Google',
              onPressed: () async {
                try {
                  final result =
                      await ref.read(authRepositoryProvider).signInWithGoogle();
                  if (result is FailedSignInResult && mounted) {
                    setState(
                      () => _errorMessage = 'You need a connection to sign in.',
                    );
                  }
                } catch (_) {
                  if (mounted) {
                    setState(
                      () => _errorMessage = 'You need a connection to sign in.',
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            SettingsValueRow(
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
            SettingsValueRow(
              title: 'Sign out',
              onTap: () => _confirmSignOut(context, ref),
            ),
            SettingsValueRow(
              title: 'Delete account',
              onTap: () => _go(context, '/settings/account/delete'),
            ),
          ],
        ],
      ),
    );
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
    if (router != null) unawaited(router.push<void>(location));
  }
}
