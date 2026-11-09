import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/public_id_provider.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/error/app_exception.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/google_sign_in_button.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/settings_toast.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

const _adultRowTitle = "I'm 18 now";

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
  bool _genericFailure = false;
  bool _failedSignOut = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Opens the age step again. If the student is now 18 or older it comes back
  /// with `true` and the account is already set to adult.
  Future<void> _recheckAge() async {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final done = await router.push<bool>('/settings/account/adult-check');
    if ((done ?? false) && mounted) {
      showSettingsToast(context, 'Your account is now set for 18 and over.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_genericFailure) {
      return StateView.fullScreen(
        onRetry: () {
          setState(() => _genericFailure = false);
          if (_failedSignOut) {
            unawaited(_confirmSignOut());
          } else {
            unawaited(_signIn());
          }
        },
      );
    }
    final user = ref.watch(currentUserProvider).valueOrNull;
    final minor = ref.watch(ageGroupProvider).valueOrNull == 'minor';
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
    final web = ref.watch(paymentsOnWebProvider);
    final sync = ref.watch(syncStatusProvider).valueOrNull;
    final backup = backupLabel(sync, now: DateTime.now());
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    Future<void> copyId() async {
      if (digits == null || user == null) return;

      final uid = user.uid;
      final telemetry = ref.read(telemetryProvider);
      try {
        await Clipboard.setData(
          ClipboardData(text: digits),
        );
      } catch (error, stack) {
        await telemetry.recordError(error, stack);
        return;
      }
      if (!mounted || ref.read(currentUserProvider).valueOrNull?.uid != uid) {
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
    }

    if (context.wideWeb) {
      final t = context.webTokens;
      return SettingsPanePage(
        section: 'Account',
        title: 'Account',
        description: 'Your name, sign-in and backup.',
        children: [
          SettingsSection(
            footer: user == null
                ? 'You get your own Pantas ID when you sign in.'
                : digits == null
                    ? "It shows up the next time you're online."
                    : 'This is safe to share publicly.',
            children: [
              SettingsRow(
                title: 'Name',
                value: settings.name ?? 'Add your name',
                divider: true,
                dividerInset:
                    context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
                onTap: () => push('/settings/account/name'),
              ),
              if (user != null)
                SettingsRow(
                  title: web ? 'Email' : 'Signed in with',
                  value: web ? user.email : 'Google',
                  variant: ListRowVariant.value,
                  divider: true,
                  dividerInset:
                      context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
                ),
              SettingsRow(
                title: 'Pantas ID',
                value: user == null
                    ? 'Sign in to get one'
                    : copied
                        ? 'Copied'
                        : displayId ?? 'Not ready yet',
                variant: ListRowVariant.value,
                trailingWidget: digits == null
                    ? null
                    : copied
                        ? Icon(
                            PantasIcons.check,
                            size: 16,
                            color: t.colors.accent,
                          )
                        : const WebKeyHint('Click to copy', keyboard: false),
                onTap: digits == null ? null : copyId,
              ),
            ],
          ),
          const SizedBox(height: PantasSpace.s24),
          if (minor) ...[
            SettingsSection(
              children: [
                SettingsRow(title: _adultRowTitle, onTap: _recheckAge),
              ],
            ),
            const SizedBox(height: PantasSpace.s24),
          ],
          if (user == null) ...[
            GoogleSignInButton(
              label: _signingIn ? 'Signing in…' : 'Continue with Google',
              busy: _signingIn,
              onPressed: _signingIn ? null : _signIn,
            ),
            if (web) ...[
              const SizedBox(height: PantasSpace.s12),
              WebButton(
                label: 'Continue with Email',
                variant: WebButtonVariant.secondary,
                onPressed: _signingIn ? null : () => push('/auth/email-link'),
              ),
            ],
            const SizedBox(height: PantasSpace.s12),
            Text(
              _errorMessage ??
                  'Your progress stays in this browser. '
                      'Signing in gives you an account you can come back to.',
              style: t.sm,
            ),
            const SizedBox(height: PantasSpace.s24),
            WebButton(
              label: 'Delete My Data',
              variant: WebButtonVariant.dangerOutline,
              onPressed: () => push('/settings/account/delete'),
            ),
          ] else ...[
            ...[
              SettingsSection(
                header: 'Backup',
                footer: pro
                    ? "Pantas backs up on its own whenever you're online."
                    : webFreeBackupNote,
                children: [
                  SettingsRow(
                    title: 'Backup',
                    value: pro ? backup : 'This browser only',
                    variant: ListRowVariant.value,
                  ),
                  if (pro)
                    SettingsRow(
                      title: 'Details',
                      onTap: () => push('/settings/backup'),
                    ),
                ],
              ),
              const SizedBox(height: PantasSpace.s24),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
              child: Wrap(
                spacing: PantasSpace.s8,
                runSpacing: PantasSpace.s8,
                children: [
                  WebTextAction(
                    label: 'Sign Out',
                    onPressed: _confirmSignOut,
                  ),
                  WebButton(
                    label: 'Delete Account',
                    variant: WebButtonVariant.tertiary,
                    redText: true,
                    height: PantasSize.btnSm,
                    radius: PantasRadius.md,
                    onPressed: () => push('/settings/account/delete'),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) Text(_errorMessage!, style: t.sm),
          ],
        ],
      );
    }
    return SettingsPanePage(
      section: 'Account',
      description: 'Your name, sign-in and backup.',
      title: context.wideWeb ? 'Account' : '',
      noHeading: true,
      backLabel: 'Settings',
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        // ST_Account: a centered 84 px avatar over a 24 px name and the email.
        Padding(
          padding: const EdgeInsets.only(
            top: PantasSpace.s10,
            bottom: PantasSpace.s6,
          ),
          child: Column(
            children: [
              Avatar(
                name: settings.name ?? '',
                size: 84,
                photo: user?.photoUrl == null
                    ? null
                    : NetworkImage(user!.photoUrl!),
              ),
              const SizedBox(height: PantasSpace.s6),
              Text(
                settings.name ?? 'Add your name',
                style: PantasType.phoneTitle2
                    .copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: PantasSpace.s10),
              Text(
                user?.email ?? 'Not signed in',
                style: PantasType.phoneExplanation
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: PantasSpace.s20),
        SettingsSection(
          children: [
            SettingsRow(
              title: 'Name',
              value: settings.name ?? 'Add your name',
              divider: user != null,
              onTap: () => push('/settings/account/name'),
            ),
            if (user != null)
              SettingsRow(
                title: web ? 'Email' : 'Signed in with',
                value: web ? user.email : 'Google',
                variant: ListRowVariant.value,
              ),
          ],
        ),
        const SizedBox(height: PantasSpace.s20),
        if (minor) ...[
          SettingsSection(
            children: [
              SettingsRow(title: _adultRowTitle, onTap: _recheckAge),
            ],
          ),
          const SizedBox(height: PantasSpace.s20),
        ],
        SettingsSection(
          footer: user == null
              ? 'You get your own Pantas ID when you sign in.'
              : digits == null
                  ? "It shows up the next time you're online."
                  : 'Tap to copy. This is safe to share publicly.',
          children: [
            SettingsRow(
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
              onTap: digits == null ? null : copyId,
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s20),
        if (user == null) ...[
          GoogleSignInButton(
            expand: true,
            busy: _signingIn,
            onPressed: _signingIn ? null : _signIn,
          ),
          if (web) ...[
            const SizedBox(height: PantasSpace.s12),
            PantasButton(
              label: 'Continue with Email',
              variant: PantasButtonVariant.secondary,
              onPressed: _signingIn ? null : () => push('/auth/email-link'),
            ),
          ],
          const SizedBox(height: PantasSpace.s12),
          Text(
            // The web build keeps the progress in the browser, whatever the
            // window size, so it says so, as the wide layout and Backup do.
            'Your progress stays ${web ? 'in this browser' : 'on this phone'}. '
            'Signing in gives you an account you can come back to.',
            style: context.type.footnote,
            textAlign: TextAlign.center,
          ),
        ] else ...[
          ...[
            SettingsSection(
              header: 'Backup',
              footer: pro
                  ? "Pantas backs up on its own whenever you're online."
                  : web
                      ? webFreeBackupNote
                      : 'Your progress stays on this phone only. With Pro, '
                          "it's backed up and syncs across your devices.",
              children: [
                SettingsRow(
                  title: 'Backup',
                  value:
                      pro ? backup : 'This ${web ? 'browser' : 'phone'} only',
                  variant: ListRowVariant.value,
                  divider: true,
                  dividerInset:
                      context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
                ),
                if (pro)
                  SettingsRow(
                    title: 'Details',
                    onTap: () => push('/settings/backup'),
                  )
                // Web leaves this out, as the wide layout does: during the
                // beta, Pro comes from the switch on Settings, not checkout.
                else if (!web)
                  SettingsRow(
                    title: 'Back Up with Pro',
                    onTap: () => push('/settings/pro'),
                  ),
              ],
            ),
          ],
          const SizedBox(height: PantasSpace.s20),
          // ST_Account: Sign Out and Delete Account are separate cards.
          SettingsSection(
            children: [
              SettingsRow(
                title: 'Sign Out',
                titleColor: context.colors.accent,
                hideChevron: true,
                onTap: _confirmSignOut,
              ),
            ],
          ),
          const SizedBox(height: PantasSpace.s20),
          SettingsSection(
            children: [
              SettingsRow(
                title: 'Delete Account',
                titleColor: context.colors.destructive,
                onTap: () => push('/settings/account/delete'),
              ),
            ],
          ),
        ],
        if (user == null) ...[
          const SizedBox(height: PantasSpace.s20),
          SettingsSection(
            children: [
              SettingsRow(
                title: 'Delete My Data',
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
      _genericFailure = false;
      _failedSignOut = false;
    });
    final telemetry = ref.read(telemetryProvider);
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
              : null,
        );
        if (_errorMessage == null) {
          setState(() => _genericFailure = true);
        }
      }
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) {
        setState(() {
          _genericFailure = !_isNetworkError(error);
          _errorMessage =
              _genericFailure ? null : 'You need a connection to sign in.';
        });
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.colors.scrim,
      builder: (context) => CenteredDialog(
        title: 'Sign out?',
        inlineActions: true,
        message: 'Your progress is saved to your account. '
            'It comes back when you sign in again.',
        primaryLabel: 'Sign Out',
        secondaryLabel: 'Cancel',
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (confirmed != true || !mounted) return;
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) {
        setState(() {
          _failedSignOut = true;
          _genericFailure = !_isNetworkError(error);
          _errorMessage =
              _genericFailure ? null : 'You need a connection to sign out.';
        });
      }
    }
  }
}

bool _isNetworkError(Object error) {
  final code = switch (error) {
    AuthGatewayException(:final code) => code,
    PlatformException(:final code) => code,
    AppException(:final code) => code,
    _ => null,
  };
  return error is NetworkException ||
      const {'network-request-failed', 'network_error'}.contains(code);
}
