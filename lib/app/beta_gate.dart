import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

final betaGateCutoff = DateTime.utc(2026, 11, 15, 16);

bool betaGateIsActive({
  required bool enabled,
  required bool web,
  required DateTime now,
}) =>
    enabled && web && now.isBefore(betaGateCutoff);

final betaGateStatusProvider = Provider<AsyncValue<bool>>((ref) {
  if (!ref.watch(betaGateActiveProvider)) return const AsyncData(true);
  return ref.watch(betaAccessProvider);
});

final betaGateActiveProvider = Provider<bool>((ref) {
  const enabled = bool.fromEnvironment('BETA_GATE');
  final now = DateTime.now();
  final active = betaGateIsActive(enabled: enabled, web: kIsWeb, now: now);
  if (active) {
    final timer = Timer(betaGateCutoff.difference(now), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return active;
});

String? betaGateRedirect({
  required String path,
  required bool active,
  required AsyncValue<bool> access,
}) {
  if (path == '/guardian' ||
      path.startsWith('/legal/') ||
      path == '/auth/email-link') {
    return null;
  }
  if (!active) return path == '/beta' ? '/home' : null;
  final selected =
      !access.isLoading && !access.hasError && (access.valueOrNull ?? false);
  if (selected) return path == '/beta' ? '/home' : null;
  return path == '/beta' ? null : '/beta';
}

class BetaGatePage extends ConsumerWidget {
  const BetaGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(betaAccessProvider);
    if (access.isLoading) {
      return const _SignInFrame(
        child: SkeletonPulse(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBlock(width: 240, height: 32, radius: 0),
              SizedBox(height: 24),
              SkeletonBlock(width: 320, height: 48, radius: 0),
            ],
          ),
        ),
      );
    }
    if (access.hasError) {
      return _SignInFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("We couldn't check beta access. Try again."),
            const SizedBox(height: 20),
            PantasButton(
              label: 'Try again',
              onPressed: () => ref.invalidate(betaAccessProvider),
            ),
            const SizedBox(height: 20),
            const Text('support@pantas.study'),
          ],
        ),
      );
    }
    if (access.valueOrNull ?? false) {
      return const _SignInFrame(child: SizedBox.shrink());
    }
    final named = ref.watch(authStateProvider).valueOrNull is SignedInAuthState;
    return EmailSignInPage(beta: true, denied: named);
  }
}

class EmailSignInPage extends ConsumerStatefulWidget {
  const EmailSignInPage({
    this.beta = false,
    this.denied = false,
    this.link,
    super.key,
  });
  final bool beta;
  final bool denied;
  final String? link;

  @override
  ConsumerState<EmailSignInPage> createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends ConsumerState<EmailSignInPage> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _message;
  String? _link;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(authRepositoryProvider);
    final link = widget.link;
    _link = link != null && repository.isEmailSignInLink(link) ? link : null;
    if (_link != null) {
      _email.text = repository.pendingEmailLinkEmail ?? '';
      if (_email.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_complete());
        });
      }
    } else if (link != null) {
      _message = 'This link is not valid. Request a new email link.';
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _act(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on Object {
      if (mounted) {
        setState(() => _message = "We couldn't sign you in. Try again.");
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _result(SignInResult result) {
    if (!mounted) return;
    if (result is FailedSignInResult) {
      setState(() {
        _message = _link == null
            ? "We couldn't sign you in. Try again."
            : 'This link could not sign you in. '
                'Check your email or request a new link.';
      });
    } else if (result is! CancelledSignInResult) {
      ref.invalidate(betaAccessProvider);
      context.go(widget.beta ? '/beta' : '/home');
    }
  }

  Future<void> _complete() => _act(() async {
        if (_email.text.trim().isEmpty) {
          setState(() {
            _message = 'Enter the email you used to request this link.';
          });
          return;
        }
        _result(
          await ref.read(authRepositoryProvider).completeEmailLink(
                _link!,
                email: _email.text,
              ),
        );
      });

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return _SignInFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: PantasLogo(size: 104)),
          const SizedBox(height: 28),
          Text(
            'Welcome to Pantas',
            textAlign: TextAlign.center,
            style: type.largeTitle,
          ),
          const SizedBox(height: 12),
          Text(
            _link != null
                ? 'Enter the email you used to request this link.'
                : widget.beta
                    ? 'Sign in with the email you applied with.'
                    : 'Sign in with your email.',
            textAlign: TextAlign.center,
            style: type.body,
          ),
          if (widget.denied) ...[
            const SizedBox(height: 24),
            const Text(
              "This email isn't on the beta list. "
              'Use the email you applied with.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          if (_link == null) ...[
            PantasButton(
              label: 'Sign in with Google',
              variant: PantasButtonVariant.secondary,
              onPressed: _busy
                  ? null
                  : () => _act(() async {
                        _result(
                          await ref
                              .read(authRepositoryProvider)
                              .signInWithGoogle(),
                        );
                      }),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
          ],
          TextField(
            controller: _email,
            enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Email'),
            onSubmitted:
                _busy ? null : (_) => _link == null ? _send() : _complete(),
          ),
          const SizedBox(height: 16),
          PantasButton(
            label: _link == null ? 'Send email link' : 'Sign in',
            onPressed:
                _busy ? null : () => _link == null ? _send() : _complete(),
          ),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Text(_message!, textAlign: TextAlign.center),
          ],
          if (_link != null)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      ref.read(authRepositoryProvider).cancelEmailLink();
                      setState(() {
                        _link = null;
                        _message = null;
                      });
                      context.go('/auth/email-link');
                    },
              child: const Text('Request a new link'),
            ),
          const SizedBox(height: 24),
          const Text('support@pantas.study', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _send() => _act(() async {
        final email = _email.text.trim();
        if (!email.contains('@')) {
          setState(() => _message = 'Enter your email address.');
          return;
        }
        await ref.read(authRepositoryProvider).sendEmailLink(
              email,
              Uri.base.resolve('/auth/email-link').toString(),
            );
        if (mounted) {
          setState(() {
            _message = 'Check your email. Open the link to sign in.';
          });
        }
      });
}

class _SignInFrame extends ConsumerWidget {
  const _SignInFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(welcomeHandoverProvider).appReady(holdForTap: false);
      }
    });
    return FirstScreenReady(
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
