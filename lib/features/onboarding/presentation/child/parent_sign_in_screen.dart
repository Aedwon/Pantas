import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/onboarding/presentation/child/child_step_frame.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

/// Where the parent's sign-in leads: the setup screen.
const String childSetupPath = '/onboarding/child/setup';

/// Where the parent's email sign-in runs. It is the app's own email-code
/// sign-in page, which returns to [childSetupPath].
const String childEmailSignInPath = '/onboarding/child/sign-in/email';

/// Board 2: the parent or guardian signs in first, by the app's named sign-in
/// (an email code or Google). The screen reads and keeps nothing about the
/// parent: the session is the only place the sign-in lives.
class ParentSignInScreen extends ConsumerStatefulWidget {
  const ParentSignInScreen({this.onSignedIn, this.onEmail, super.key});

  /// Defaults to the setup screen.
  final VoidCallback? onSignedIn;

  /// Defaults to the email-code sign-in page.
  final VoidCallback? onEmail;

  @override
  ConsumerState<ParentSignInScreen> createState() => _ParentSignInScreenState();
}

class _ParentSignInScreenState extends ConsumerState<ParentSignInScreen> {
  bool _google = false;
  bool _dismissed = false;
  String? _message;

  Future<void> _signInWithGoogle() async {
    if (_google) return;
    setState(() {
      _google = true;
      _message = null;
      _dismissed = false;
    });
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (!mounted) return;
      switch (result) {
        case FailedSignInResult():
          setState(() => _message = "We couldn't sign you in. Try again.");
        case CancelledSignInResult():
          break;
        case LinkedExistingSignInResult() || SwitchedToExistingSignInResult():
          _signedIn();
      }
    } on Object {
      if (mounted) {
        setState(() => _message = "We couldn't sign you in. Try again.");
      }
    } finally {
      if (mounted) setState(() => _google = false);
    }
  }

  void _signedIn() {
    final custom = widget.onSignedIn;
    if (custom != null) return custom();
    GoRouter.maybeOf(context)?.go(childSetupPath);
  }

  void _back() {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/onboarding');
    }
  }

  void _email() {
    final custom = widget.onEmail;
    if (custom != null) return custom();
    unawaited(GoRouter.maybeOf(context)?.push<void>(childEmailSignInPath));
  }

  /// Both buttons, the main one on top. Two long labels do not fit side by
  /// side on wide web, so they stack there too.
  Widget _actions(BuildContext context) {
    final buttons = <Widget>[
      OnboardingButton(
        label: ChildSetupCopy.continueWithGoogle,
        busy: _google,
        onPressed: _google ? null : () => unawaited(_signInWithGoogle()),
      ),
      const SizedBox(height: PantasSpace.s8),
      OnboardingButton(
        label: ChildSetupCopy.continueWithEmail,
        variant: PantasButtonVariant.neutral,
        onPressed: _google ? null : _email,
      ),
    ];
    if (!context.wideWeb) return OnboardingActions(children: buttons);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) => OnboardingWebPage(
        title: ChildSetupCopy.signInTitle,
        detail: ChildSetupCopy.signInLead,
        onBack: _back,
        bodyGap: childStepGap,
        bottom: _actions(context),
        children: [
          if (_message != null && !_dismissed)
            ChildStepNotice(
              title: _message!,
              onClose: () => setState(() => _dismissed = true),
            ),
        ],
      );
}
