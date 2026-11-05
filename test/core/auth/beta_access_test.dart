import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';

import 'firebase_auth_functions_gateway_test.dart'
    show RecordingFunctionsClient;

void main() {
  test('selection callable derives identity without a client email', () async {
    final client = RecordingFunctionsClient(
      responses: {
        'getBetaAccess': {'selected': true},
      },
    );
    expect(await BetaAccessGateway(client: client).check(), isTrue);
    expect(client.calls.single.name, 'getBetaAccess');
    expect(client.calls.single.region, 'asia-southeast1');
  });

  test('malformed selection responses fail closed', () async {
    for (final response in [
      null,
      <String, Object?>{},
      {'selected': 'true'},
    ]) {
      final client = RecordingFunctionsClient(
        responses: {'getBetaAccess': response},
      );
      await expectLater(
        BetaAccessGateway(client: client).check(),
        throwsA(isA<AuthGatewayException>()),
      );
    }
  });

  test('disabled gate never calls the selection service', () async {
    final client = RecordingFunctionsClient();
    final container = ProviderContainer(
      overrides: [
        betaGateActiveProvider.overrideWithValue(false),
        betaAccessGatewayProvider.overrideWithValue(
          BetaAccessGateway(client: client),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(betaGateStatusProvider).valueOrNull, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(client.calls, isEmpty);
  });

  test('anonymous users never call selection', () async {
    final client = RecordingFunctionsClient();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.anonymous(uid: 'anon')),
        ),
        betaAccessGatewayProvider.overrideWithValue(
          BetaAccessGateway(client: client),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(betaAccessProvider.future), isFalse);
    expect(client.calls, isEmpty);
  });

  test('switching accounts discards the previous account selection', () async {
    final states = StreamController<AuthState>();
    final gateway = _PendingAccess();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => states.stream),
        betaAccessGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(states.close);
    final subscription = container.listen(betaAccessProvider, (_, __) {});
    addTearDown(subscription.close);
    states.add(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'first',
          email: 'first@example.com',
          displayName: '',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    states.add(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'second',
          email: 'second@example.com',
          displayName: '',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    gateway.requests.first.complete(true);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(betaAccessProvider).isLoading, isTrue);
    gateway.requests.last.complete(false);
    expect(await container.read(betaAccessProvider.future), isFalse);
  });
}

class _PendingAccess extends BetaAccessGateway {
  final requests = <Completer<bool>>[];
  @override
  Future<bool> check() {
    final result = Completer<bool>();
    requests.add(result);
    return result.future;
  }
}
