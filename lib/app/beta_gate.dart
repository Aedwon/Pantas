import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

final betaGateCutoff = DateTime.utc(2026, 11, 15, 16);

bool betaGateIsActive({
  required bool enabled,
  required bool web,
  required DateTime now,
}) =>
    enabled && web && now.isBefore(betaGateCutoff);

final betaGateStatusProvider = Provider<AsyncValue<bool>>((ref) {
  if (!ref.watch(betaGateActiveProvider)) return const AsyncData(true);
  // While the sign-in screen plays its signed-in beat, the gate stays put.
  if (ref.watch(signInHoldProvider)) return const AsyncLoading();
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
    final named = ref.watch(authStateProvider).valueOrNull is SignedInAuthState;
    // The sign-in screen is playing its signed-in beat. Keep it.
    if (ref.watch(signInHoldProvider)) return const EmailSignInPage(beta: true);
    if (access.isLoading) {
      return const _CenteredFrame(
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
      return _CenteredFrame(
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
      return const _CenteredFrame(child: SizedBox.shrink());
    }
    return EmailSignInPage(beta: true, denied: named);
  }
}

/// The page for the gate's own loading and error states.
class _CenteredFrame extends StatelessWidget {
  const _CenteredFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SignInFrame(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: child,
            ),
          ),
        ),
      );
}
