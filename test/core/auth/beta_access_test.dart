import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';

import 'firebase_auth_functions_gateway_test.dart'
    show RecordingFunctionsClient;

void main() {
  test('selection callable derives identity without a client email', () async {
    final client = RecordingFunctionsClient(
      responses: {
        'getBetaAccess': {'selected': true},
      },
    );
    expect(await BetaAccessGateway(client: client).check(), BetaAccess.open);
    expect(client.calls.single.name, 'getBetaAccess');
    expect(client.calls.single.region, 'asia-southeast1');
  });

  test('the wait date is read as a UTC instant', () async {
    final start = DateTime.utc(2026, 11, 8, 16);
    for (final value in <Object>[
      start.millisecondsSinceEpoch,
      start.millisecondsSinceEpoch.toDouble(),
    ]) {
      final client = RecordingFunctionsClient(
        responses: {
          'getBetaAccess': {'selected': true, 'waitUntil': value},
        },
      );
      final access = await BetaAccessGateway(client: client).check();
      expect(access.selected, isTrue);
      expect(access.waitUntil, start);
      expect(
        access.isWaiting(start.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(access.isWaiting(start), isFalse);
      expect(access.canEnter(start), isTrue);
    }
  });

  test('a response with no wait date has no wait', () async {
    final client = RecordingFunctionsClient(
      responses: {
        'getBetaAccess': {'selected': true, 'waitUntil': null},
      },
    );
    final access = await BetaAccessGateway(client: client).check();
    expect(access.waitUntil, isNull);
    expect(access.isWaiting(DateTime.utc(2026)), isFalse);
    expect(access.canEnter(DateTime.utc(2026)), isTrue);
  });

  test('malformed selection responses fail closed', () async {
    for (final response in [
      null,
      <String, Object?>{},
      {'selected': 'true'},
      {'selected': true, 'waitUntil': 'soon'},
      {'selected': true, 'waitUntil': true},
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
    expect(
      container.read(betaGateStatusProvider).valueOrNull,
      BetaAccess.open,
    );
    await Future<void>.delayed(Duration.zero);
    expect(client.calls, isEmpty);
  });

  test('the timeline marks the beta answer when it arrives', () async {
    PerfTimeline.reset();
    addTearDown(PerfTimeline.reset);
    final pending = Completer<BetaAccess>();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(
            const AuthState.signedIn(
              user: AuthUser(uid: 'u', email: 'u@example.com', displayName: ''),
            ),
          ),
        ),
        betaAccessGatewayProvider.overrideWithValue(
          _CompleterAccess(pending),
        ),
      ],
    );
    addTearDown(container.dispose);
    final answer = container.read(betaAccessProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(PerfTimeline.entries(), isEmpty, reason: 'still waiting');

    pending.complete(BetaAccess.open);
    await answer;

    expect(PerfTimeline.entries().map((e) => e.name), ['beta.resolved']);
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
    expect(
      await container.read(betaAccessProvider.future),
      BetaAccess.denied,
    );
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
    gateway.requests.first.complete(BetaAccess.open);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(betaAccessProvider).isLoading, isTrue);
    gateway.requests.last.complete(BetaAccess.denied);
    expect(
      await container.read(betaAccessProvider.future),
      BetaAccess.denied,
    );
  });
}

class _PendingAccess extends BetaAccessGateway {
  final requests = <Completer<BetaAccess>>[];
  @override
  Future<BetaAccess> check() {
    final result = Completer<BetaAccess>();
    requests.add(result);
    return result.future;
  }
}

class _CompleterAccess implements BetaAccessGateway {
  _CompleterAccess(this._result);
  final Completer<BetaAccess> _result;

  @override
  Future<BetaAccess> check() => _result.future;
}
