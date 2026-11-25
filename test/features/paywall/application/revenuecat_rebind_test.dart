import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/paywall.dart';

import '../../../helpers/in_memory_database.dart';

// Staging, Nov 26: a Pro account showed Free in the nav after onboarding
// until a reload. Onboarding (and an exam change in Settings) refreshes the app
// preferences, which rebuilds the payment gateway. The startup sign-in kept the
// old gateway, so the new one never had the account.
void main() {
  late StreamController<AuthSession?> sessions;
  late _Auth auth;
  late ProviderContainer container;
  late List<_RecordingGateway> gateways;

  setUp(() {
    sessions = StreamController<AuthSession?>.broadcast();
    auth = _Auth(sessions);
    gateways = [];
    final db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(AuthRepository(gateway: auth)),
        // The real gateway depends on the preferences the same way.
        revenueCatGatewayProvider.overrideWith((ref) {
          ref.watch(appPreferencesRepositoryProvider);
          final gateway = _RecordingGateway();
          gateways.add(gateway);
          ref.onDispose(() => unawaited(gateway.clearIdentity()));
          return gateway;
        }),
        // The real binding, without the Firestore claims listener.
        revenueCatAuthBindingProvider.overrideWith((ref) {
          final binding =
              RevenueCatAuthBinding(ref.watch(revenueCatBootstrapperProvider));
          ref.onDispose(() => unawaited(binding.dispose()));
          return binding;
        }),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await sessions.close();
      await db.close();
    });
  });

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('a preferences refresh after sign-in keeps the account on the gateway',
      () async {
    auth.current = const AuthSession(uid: 'pro-user', email: 'p@example.test');
    await bootstrapRevenueCat(container);
    expect(gateways.single.loggedInUids, ['pro-user']);

    // What onboarding and the exam page do.
    container.invalidate(appPreferencesRepositoryProvider);
    final current = container.read(revenueCatGatewayProvider);
    await settle();

    expect(gateways, hasLength(2));
    expect(identical(current, gateways.last), isTrue);
    expect(gateways.last.loggedInUids, ['pro-user']);
  });

  test('an exam change in Settings keeps the account on the gateway', () async {
    auth.current = const AuthSession(uid: 'pro-user', email: 'p@example.test');
    await bootstrapRevenueCat(container);

    // What the exam page does after an exam change (exam_page.dart).
    container
      ..invalidate(appPreferencesRepositoryProvider)
      ..invalidate(activeExamFocusProvider);
    final current = container.read(revenueCatGatewayProvider);
    await settle();

    expect(identical(current, gateways.last), isTrue);
    expect(gateways.last.loggedInUids, ['pro-user']);
  });

  test('an account switch after a refresh signs out the gateway in use',
      () async {
    auth.current = const AuthSession(uid: 'pro-user', email: 'p@example.test');
    await bootstrapRevenueCat(container);
    container
      ..invalidate(appPreferencesRepositoryProvider)
      ..read(revenueCatGatewayProvider);
    await settle();
    final current = gateways.last;
    final clearsBefore = current.clearCount;

    // The auth repository calls this hook before it changes the account.
    await container.read(authRepositoryProvider).beforeIdentityChange?.call();
    expect(current.clearCount, clearsBefore + 1);

    auth.current =
        const AuthSession(uid: 'other-user', email: 'o@example.test');
    sessions.add(auth.current);
    await settle();
    expect(current.loggedInUids.last, 'other-user');
  });
}

class _RecordingGateway extends DisabledRevenueCatGateway {
  final loggedInUids = <String>[];
  int clearCount = 0;

  @override
  Future<void> logIn(String uid) async => loggedInUids.add(uid);

  @override
  Future<void> clearIdentity() async => clearCount++;

  @override
  Future<void> logOut() async {}
}

class _Auth implements AuthGateway {
  _Auth(this._sessions);

  final StreamController<AuthSession?> _sessions;
  AuthSession? current;

  @override
  AuthSession? get currentSession => current;

  @override
  Stream<AuthSession?> get authStateChanges async* {
    yield current;
    yield* _sessions.stream;
  }

  @override
  Future<AuthSession> signInAnonymously() => throw UnimplementedError();

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<AuthSession> signInWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<void> reauthenticateWithGoogleCredential(GoogleAuthTokens tokens) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}
