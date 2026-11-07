import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/providers.dart';

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

final betaAccessProvider = FutureProvider<BetaAccess>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  if (state is! SignedInAuthState) return BetaAccess.denied;
  return ref.watch(betaAccessGatewayProvider).check();
});
