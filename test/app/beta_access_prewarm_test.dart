import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';

class _CountingGateway extends BetaAccessGateway {
  _CountingGateway({this.fail = false});
  final bool fail;
  int calls = 0;

  @override
  Future<BetaAccess> check() async {
    calls++;
    if (fail) throw StateError('offline');
    return BetaAccess.open;
  }
}

AuthState signedIn(String uid) => AuthState.signedIn(
      user: AuthUser(uid: uid, email: '$uid@example.com', displayName: uid),
    );

void main() {
  late StreamController<AuthState> auth;
  setUp(() => auth = StreamController<AuthState>());
  // A single-subscription stream nobody listened to never reports closed.
  tearDown(() => unawaited(auth.close()));

  ProviderContainer containerFor(
    _CountingGateway gateway, {
    required bool active,
  }) {
    final container = ProviderContainer(
      overrides: [
        betaGateActiveProvider.overrideWithValue(active),
        betaAccessGatewayProvider.overrideWithValue(gateway),
        authStateProvider.overrideWith((ref) => auth.stream),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('an active gate and a signed-in account start one check at startup',
      () async {
    final gateway = _CountingGateway();
    final container = containerFor(gateway, active: true);

    startBetaAccessCheck(container);
    auth.add(signedIn('u1'));
    await pumpEventQueue();
    expect(gateway.calls, 1);

    // The router reads the same provider and reuses the result.
    final status = container.read(betaGateStatusProvider);
    expect(status.valueOrNull, BetaAccess.open);
    expect(gateway.calls, 1);
  });

  test('an inactive gate checks nothing', () async {
    final gateway = _CountingGateway();
    final container = containerFor(gateway, active: false);

    startBetaAccessCheck(container);
    auth.add(signedIn('u1'));
    await pumpEventQueue();

    expect(gateway.calls, 0);
  });

  test('an anonymous account does not call the server', () async {
    final gateway = _CountingGateway();
    final container = containerFor(gateway, active: true);

    startBetaAccessCheck(container);
    auth.add(const AuthState.anonymous(uid: 'anon'));
    await pumpEventQueue();

    expect(gateway.calls, 0);
  });

  test('a changed identity still checks again', () async {
    final gateway = _CountingGateway();
    final container = containerFor(gateway, active: true);

    startBetaAccessCheck(container);
    auth.add(signedIn('u1'));
    await pumpEventQueue();
    container.listen(betaAccessProvider, (_, __) {});
    auth.add(signedIn('u2'));
    await pumpEventQueue();

    expect(gateway.calls, 2);
  });

  test('a failed early check is ignored and the gate sees the error', () async {
    final gateway = _CountingGateway(fail: true);
    final container = containerFor(gateway, active: true);

    startBetaAccessCheck(container);
    auth.add(signedIn('u1'));
    await pumpEventQueue();

    expect(gateway.calls, 1);
    expect(container.read(betaGateStatusProvider).hasError, isTrue);
  });
}
