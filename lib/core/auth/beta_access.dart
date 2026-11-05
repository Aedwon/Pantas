import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/providers.dart';

class BetaAccessGateway {
  const BetaAccessGateway({
    AuthFunctionsCallableClient? client,
  }) : _client = client ?? const FirebaseFunctionsCallableClient();
  final AuthFunctionsCallableClient _client;

  Future<bool> check() async {
    final result = await _client.call(
      region: FirebaseAuthFunctionsGateway.region,
      name: 'getBetaAccess',
    );
    if (result is! Map || result['selected'] is! bool) {
      throw const AuthGatewayException('malformed-beta-access-response');
    }
    return result['selected'] as bool;
  }
}

final betaAccessGatewayProvider = Provider<BetaAccessGateway>(
  (ref) => const BetaAccessGateway(),
);

final betaAccessProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  if (state is! SignedInAuthState) return false;
  return ref.watch(betaAccessGatewayProvider).check();
});
