import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';

/// The student waits here until a parent or guardian confirms. A declined or
/// expired link looks the same: the student can resend or change the email.
class GuardianWaitingPage extends ConsumerStatefulWidget {
  const GuardianWaitingPage({this.onChangeEmail, this.onCleared, super.key});

  /// Defaults to the contact form.
  final VoidCallback? onChangeEmail;

  /// Defaults to resuming onboarding.
  final VoidCallback? onCleared;

  @override
  ConsumerState<GuardianWaitingPage> createState() =>
      _GuardianWaitingPageState();
}

class _GuardianWaitingPageState extends ConsumerState<GuardianWaitingPage> {
  GuardianStatus? _status;
  String? _fallbackMask;
  bool _loadFailed = false;
  bool _busy = false;
  bool _actionFailed = false;
  Future<void> Function()? _lastAction;

  /// The one line of feedback under the buttons, or null for none.
  String? _notice;

  static const _emailSent = 'Email sent.';
  static const _resendFailed = 'Could not send the email. Try again.';
  static const _notConfirmed = 'Not confirmed yet.';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  void _changeEmail() {
    final custom = widget.onChangeEmail;
    if (custom != null) return custom();
    unawaited(context.push('/guardian/contact'));
  }

  void _cleared() {
    final custom = widget.onCleared;
    if (custom != null) return custom();
    context.go('/onboarding');
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    final contact =
        await ref.read(appPreferencesRepositoryProvider).guardianContact();
    if (contact != null) _fallbackMask = maskEmail(contact.email);
    try {
      final status = await ref.read(guardianControllerProvider).refresh();
      if (!mounted) return;
      if (status.status == GuardianConsentStatus.confirmed) return _cleared();
      setState(() => _status = status);
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  Future<void> _run(
    Future<void> Function() action, {
    String? failureNotice,
  }) async {
    if (_busy) return;
    _lastAction = action;
    setState(() {
      _busy = true;
      _actionFailed = false;
      _notice = null;
    });
    try {
      await action();
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      if (mounted) {
        setState(() {
          if (failureNotice == null) {
            _actionFailed = true;
          } else {
            _notice = failureNotice;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkAgain() => _run(() async {
        final status = await ref.read(guardianControllerProvider).refresh();
        if (!mounted) return;
        if (status.status == GuardianConsentStatus.confirmed) return _cleared();
        setState(() {
          _status = status;
          _notice = _notConfirmed;
        });
      });

  Future<void> _resend() => _run(
        () async {
          final status = await ref.read(guardianControllerProvider).resend();
          if (!mounted) return;
          if (status == null) return _changeEmail();
          setState(() {
            _status = status;
            _notice = _emailSent;
          });
        },
        failureNotice: _resendFailed,
      );

  static String _unbroken(String text) => text.replaceAll(' ', '\u00A0');

  String? get _body {
    final status = _status;
    final masked = status?.maskedEmail ?? _fallbackMask;
    if (masked == null) return null;
    final expiry = status?.expiresAt;
    return [
      'We emailed $masked.',
      // No line break inside the date: "Nov 12," never ends a line with
      // "2026." alone on the next.
      if (expiry != null)
        'The link expires on ${_unbroken(guardianDateLabel(expiry))}.',
      'Pantas opens here once they confirm.',
    ].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Scaffold(body: errorFor('status', _load));
    }
    if (_status == null) {
      return Scaffold(body: loadingFor(const AsyncLoading<void>()));
    }
    return GuardianScreen(
      title: 'Waiting for your parent or guardian',
      detail: _body,
      actions: [
        if (_actionFailed && _lastAction != null)
          saveFailureLine(() => unawaited(_run(_lastAction!))),
        PantasButton(
          label: 'Check Again',
          variant: PantasButtonVariant.secondary,
          busy: _busy,
          onPressed: _busy ? null : _checkAgain,
        ),
        PantasButton(
          label: 'Resend Email',
          variant: PantasButtonVariant.tertiary,
          onPressed: _busy ? null : _resend,
        ),
        PantasButton(
          label: 'Change Email',
          variant: PantasButtonVariant.tertiary,
          onPressed: _busy ? null : _changeEmail,
        ),
        // The line always has its place. The group is centered, so a line that
        // appeared only when it had something to say moved the title, the body
        // and the buttons each time.
        ExcludeSemantics(
          excluding: _notice == null,
          child: Semantics(
            liveRegion: true,
            child: Text(
              _notice ?? '\u00A0',
              textAlign: TextAlign.center,
              style: context.type.subhead
                  .copyWith(color: context.colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
