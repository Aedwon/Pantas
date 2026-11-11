import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/beta_waiting_page.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/sign_in/sign_in_parts.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

final betaGateCutoff = DateTime.utc(2026, 11, 15, 16);

bool betaGateIsActive({
  required bool enabled,
  required bool web,
  required DateTime now,
}) =>
    enabled && web && now.isBefore(betaGateCutoff);

final betaGateStatusProvider = Provider<AsyncValue<BetaAccess>>((ref) {
  if (!ref.watch(betaGateActiveProvider)) {
    return const AsyncData(BetaAccess.open);
  }
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

/// Starts the beta check during startup, so its server call runs beside the
/// rest of startup instead of after it. It does nothing unless the gate is
/// active and a named account is signed in, the same test the gate applies.
/// The router reads [betaAccessProvider] for the same result, so this makes no
/// second call, and a changed identity still checks again. The check is not
/// awaited and its errors are ignored here: the gate shows them as before.
void startBetaAccessCheck(ProviderContainer container) {
  if (!container.read(betaGateActiveProvider)) return;
  unawaited(_checkBetaAccess(container));
}

Future<void> _checkBetaAccess(ProviderContainer container) async {
  try {
    final auth = await container.read(authStateProvider.future);
    if (auth is! SignedInAuthState) return;
    await container.read(betaAccessProvider.future);
  } on Object catch (error) {
    debugPrint('Early beta check did not finish: $error');
  }
}

String? betaGateRedirect({
  required String path,
  required bool active,
  required AsyncValue<BetaAccess> access,
  required DateTime now,
}) {
  if (path == '/guardian' ||
      path.startsWith('/legal/') ||
      path == '/auth/email-link') {
    return null;
  }
  if (!active) return path == '/beta' ? '/home' : null;
  // A selected tester who must still wait stays on the waiting screen.
  final entered = !access.isLoading &&
      !access.hasError &&
      (access.valueOrNull?.canEnter(now) ?? false);
  if (entered) return path == '/beta' ? '/home' : null;
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
              SizedBox(height: PantasSpace.s24),
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
            const SizedBox(height: PantasSpace.s20),
            PantasButton(
              label: 'Try again',
              onPressed: () => ref.invalidate(betaAccessProvider),
            ),
            const SizedBox(height: PantasSpace.s20),
            const Text('support@pantas.study'),
          ],
        ),
      );
    }
    final granted = access.valueOrNull;
    if (granted != null && granted.selected) {
      final now = ref.read(betaClockProvider)();
      final until = granted.waitUntil;
      if (granted.isWaiting(now) && until != null) {
        return BetaWaitingPage(
          until: until,
          email: _signedInEmail(ref),
        );
      }
      return const _CenteredFrame(child: SizedBox.shrink());
    }
    return EmailSignInPage(beta: true, denied: named);
  }
}

String _signedInEmail(WidgetRef ref) {
  final state = ref.watch(authStateProvider).valueOrNull;
  return state is SignedInAuthState ? state.user.email : '';
}

/// The page for the gate's own loading and error states.
class _CenteredFrame extends StatelessWidget {
  const _CenteredFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SignInFrame(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PantasSpace.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: child,
            ),
          ),
        ),
      );
}
