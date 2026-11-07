import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';

/// What the server says about the signed-in account.
///
/// A selected tester is held on the waiting screen until [waitUntil]. Owner
/// test accounts and the early-access list never get one.
@immutable
class BetaAccess {
  const BetaAccess({required this.selected, this.waitUntil});

  static const denied = BetaAccess(selected: false);
  static const open = BetaAccess(selected: true);

  final bool selected;

  /// When the beta starts for this tester, in UTC. Null when there is no wait.
  final DateTime? waitUntil;

  /// True while a selected tester must still wait at [now].
  bool isWaiting(DateTime now) {
    final until = waitUntil;
    return selected && until != null && now.isBefore(until);
  }

  /// True when the tester may use the app at [now].
  bool canEnter(DateTime now) => selected && !isWaiting(now);

  @override
  bool operator ==(Object other) =>
      other is BetaAccess &&
      other.selected == selected &&
      other.waitUntil == waitUntil;

  @override
  int get hashCode => Object.hash(selected, waitUntil);
}

class BetaAccessGateway {
  const BetaAccessGateway({
    AuthFunctionsCallableClient? client,
  }) : _client = client ?? const FirebaseFunctionsCallableClient();
  final AuthFunctionsCallableClient _client;

  Future<BetaAccess> check() async {
    final result = await _client.call(
      region: FirebaseAuthFunctionsGateway.region,
      name: 'getBetaAccess',
    );
    if (result is! Map || result['selected'] is! bool) {
      throw const AuthGatewayException('malformed-beta-access-response');
    }
    final waitUntil = result['waitUntil'];
    if (waitUntil != null && waitUntil is! num) {
      throw const AuthGatewayException('malformed-beta-access-response');
    }
    return BetaAccess(
      selected: result['selected'] as bool,
      waitUntil: waitUntil == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (waitUntil as num).toInt(),
              isUtc: true,
            ),
    );
  }
}

final betaAccessGatewayProvider = Provider<BetaAccessGateway>(
  (ref) => const BetaAccessGateway(),
);

/// The clock the gate and the waiting screen read. Tests replace it.
final betaClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The account the beta check is about: its uid and email, or null when no
/// named account is signed in. The auth stream also emits for token
/// refreshes and Pro claims on the same account; those must not re-run the
/// check, or the gate shows loading and every screen behind it replays.
String? _betaIdentity(AuthState state) => state is SignedInAuthState
    ? '${state.user.uid}\n${state.user.email}'
    : null;

final betaAccessProvider = FutureProvider<BetaAccess>((ref) async {
  final identity =
      await ref.watch(authStateProvider.selectAsync(_betaIdentity));
  final access = identity == null
      ? BetaAccess.denied
      : await ref.watch(betaAccessGatewayProvider).check();
  PerfTimeline.mark('beta.resolved');
  return access;
});
