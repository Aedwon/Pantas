import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Account', backLabel: 'Settings'),
          const SizedBox(height: 16),
          if (user == null) ...[
            Text(
              'Your progress stays on this device. Signing in gives you an '
              'account, but does not by itself back up local progress. Cloud '
              'sync is available with Pantas Pro.',
              style: context.textStyles.bodyMedium
                  .copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  style: context.textStyles.bodySmall
                      .copyWith(color: context.colors.rust),
                ),
              ),
              const SizedBox(height: 12),
            ],
            BoardButton(
              label: 'Sign in with Google',
              onPressed: _signIn,
            ),
            const SizedBox(height: 24),
            SettingsValueRow(
              title: 'Delete my data',
              onTap: () => _go(context, '/settings/account/delete'),
            ),
          ] else ...[
            Text(
              user.displayName.isNotEmpty ? user.displayName : 'Account',
              style: context.textStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.inkMuted),
            ),
            const SizedBox(height: 12),
            Text(
              user.isPro
                  ? 'Pantas Pro can sync eligible study progress across your '
                      'signed-in devices.'
                  : 'Your study progress stays on this device. Cloud sync is '
                      'available with Pantas Pro.',
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

  Future<void> _signIn() async {
    if (mounted) setState(() => _errorMessage = null);

    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      if (result is FailedSignInResult) {
        setState(() => _errorMessage = 'You need a connection to sign in.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'You need a connection to sign in.');
      }
    }
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
          'Your study progress on this device will be cleared. Only progress '
          'already synced through Pantas Pro may be available after you sign '
          'in again.',
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
