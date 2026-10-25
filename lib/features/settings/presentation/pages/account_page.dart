import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/settings.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});
  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  String? _errorMessage;
  String? _copied;
  String? _copiedUid;
  Timer? _timer;
  bool _signingIn = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final id = ref.watch(publicIdProvider).valueOrNull ??
        const PublicIdState.notReady();
    final digits = user == null ? null : id.digits;
    final copied =
        digits != null && _copied == digits && _copiedUid == user?.uid;
    final displayId = digits == null
        ? null
        : digits.length == 9
            ? '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
                '${digits.substring(6)}'
            : digits;
    final pro =
        ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false;
    final sync = ref.watch(syncStatusProvider).valueOrNull;
    final backup = switch (sync) {
      SyncUpToDate() || SyncOk() => 'Saved',
      Syncing() || SyncActivating() => 'Backing up',
      SyncOffline() => 'Offline',
      SyncError() ||
      SyncFailedSince() ||
      SyncPartialFailure() =>
        "Couldn't back up",
      _ => 'Not backed up'
    };
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    return PantasPage(
      title: '',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Avatar(
                name: settings.name ?? '',
                photo: user?.photoUrl == null
                    ? null
                    : NetworkImage(user!.photoUrl!),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.name ?? 'Add your name',
                      style: context.type.emphasized.copyWith(fontSize: 22),
                    ),
                    Text(
                      user?.email ?? 'Not signed in',
                      style: context.type.subhead,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GroupedSection(
          children: [
            ListRow(
              title: 'Name',
              value: settings.name ?? 'Add your name',
              divider: user != null,
              onTap: () => push('/settings/account/name'),
            ),
            if (user != null)
              const ListRow(
                title: 'Signed in with',
                value: 'Google',
                variant: ListRowVariant.value,
              ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          footer: user == null
              ? 'You get your own Pantas ID when you sign in.'
              : digits == null
                  ? "It shows up the next time you're online."
                  : 'Tap to copy. This is safe to share publicly.',
          children: [
            ListRow(
              title: 'Pantas ID',
              trailingWidget: digits == null
                  ? null
                  : Icon(
                      copied ? PantasIcons.check : PantasIcons.copy,
                      size: 16,
                      color: copied
                          ? context.colors.accent
                          : context.colors.secondaryLabel,
                    ),
              value: user == null
                  ? 'Sign in to get one'
                  : copied
                      ? 'Copied'
                      : displayId ?? 'Not ready yet',
              variant: ListRowVariant.value,
              onTap: digits == null
                  ? null
                  : () async {
                      final uid = user!.uid;
                      try {
                        await Clipboard.setData(
                          ClipboardData(text: digits),
                        );
                      } catch (_) {
                        return;
                      }
                      if (!mounted ||
                          ref.read(currentUserProvider).valueOrNull?.uid !=
                              uid) {
                        return;
                      }
                      _timer?.cancel();
                      setState(() {
                        _copied = digits;
                        _copiedUid = uid;
                      });
                      _timer = Timer(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _copied = null);
                      });
                    },
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (user == null) ...[
          PantasButton(
            label: 'Continue with Google',
            busy: _signingIn,
            onPressed: _signingIn ? null : _signIn,
          ),
          const SizedBox(height: 12),
          Text(
            'Your progress stays on this phone. Signing in gives you an '
            'account you can come back to.',
            style: context.type.footnote,
            textAlign: TextAlign.center,
          ),
        ] else ...[
          GroupedSection(
            header: 'Backup',
            footer: pro
                ? "Pantas backs up on its own whenever you're online."
                : "Your progress stays on this phone only. With Pro, it's "
                    'backed up and syncs across your devices.',
            children: [
              ListRow(
                title: 'Backup',
                value: pro ? backup : 'This phone only',
                variant: ListRowVariant.value,
                divider: true,
              ),
              if (pro)
                ListRow(
                  title: 'Details',
                  onTap: () => push('/settings/backup'),
                )
              else
                ListRow(
                  title: 'Back Up with Pro',
                  onTap: () => push('/settings/pro'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          GroupedSection(
            children: [
              ListRow(title: 'Sign Out', onTap: _confirmSignOut, divider: true),
              ListRow(
                title: 'Delete Account',
                variant: ListRowVariant.destructive,
                onTap: () => push('/settings/account/delete'),
              ),
            ],
          ),
        ],
        if (user == null) ...[
          const SizedBox(height: 24),
          GroupedSection(
            children: [
              ListRow(
                title: 'Delete my data',
                variant: ListRowVariant.destructive,
                onTap: () => push('/settings/account/delete'),
              ),
            ],
          ),
        ],
        if (_errorMessage != null)
          Semantics(
            liveRegion: true,
            child: Text(_errorMessage!, style: context.type.footnote),
          ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _errorMessage = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      if (result is FailedSignInResult) {
        setState(
          () => _errorMessage = const {
            'network-request-failed',
            'network_error',
          }.contains(result.reason)
              ? 'You need a connection to sign in.'
              : 'Could not sign in. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'You need a connection to sign in.');
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CenteredDialog(
        title: 'Sign out?',
        message: 'Your study progress on this device will be cleared. Only '
            'progress already synced through Pantas Pro may be '
            'available after you sign in again.',
        primaryLabel: 'Sign Out',
        secondaryLabel: 'Cancel',
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'You need a connection to sign out.');
      }
    }
  }
}
