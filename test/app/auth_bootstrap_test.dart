import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/auth_bootstrap.dart';
import 'package:pantas/app/firebase_bootstrap.dart';
import 'package:pantas/core/auth/auth.dart';

void main() {
  test('configured Firebase installs a concrete live AuthRepository', () {
    var gatewayBuilds = 0;
    final gateway = BootstrapAuthGateway();
    final container = ProviderContainer(
      overrides: authRepositoryOverrides(
        FirebaseBootstrapResult.configured,
        authGatewayBuilder: () {
          gatewayBuilds += 1;
          return gateway;
        },
        googleGatewayBuilder: UnconfiguredGoogleSignInGateway.new,
        functionsGatewayBuilder: UnconfiguredAuthFunctionsGateway.new,
        localStateWiperBuilder: (_) => const NoopLocalStateWiper(),
      ),
    );
    addTearDown(container.dispose);

    expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    expect(gatewayBuilds, 1);
  });

  test(
    'unavailable Firebase installs signed-out fail-open repository',
    () async {
      final container = ProviderContainer(
        overrides: authRepositoryOverrides(FirebaseBootstrapResult.unavailable),
      );
      addTearDown(container.dispose);

      expect(
        await container.read(authStateProvider.future),
        const AuthState.signedOut(),
      );
      await expectLater(
        container.read(authRepositoryProvider).ensureAnonymous(),
        throwsA(
          isA<AuthGatewayException>().having(
            (error) => error.code,
            'code',
            'firebase-unavailable',
          ),
        ),
      );
    },
  );

  test('cached named user is preserved during Auth bootstrap', () async {
    final gateway = BootstrapAuthGateway(
      currentSession: const AuthSession(
        uid: 'named-1',
        email: 'reader@example.com',
      ),
    );
    final container = _configuredContainer(gateway);
    addTearDown(container.dispose);

    await bootstrapAuthSession(container, FirebaseBootstrapResult.configured);

    expect(gateway.signInAnonymouslyCalls, 0);
  });

  test('cached anonymous user is preserved during Auth bootstrap', () async {
    final gateway = BootstrapAuthGateway(
      currentSession: const AuthSession(uid: 'anon-1', isAnonymous: true),
    );
    final container = _configuredContainer(gateway);
    addTearDown(container.dispose);

    await bootstrapAuthSession(container, FirebaseBootstrapResult.configured);

    expect(gateway.signInAnonymouslyCalls, 0);
  });

  test(
    'empty Auth session creates an anonymous user when configured',
    () async {
      final gateway = BootstrapAuthGateway();
      final container = _configuredContainer(gateway);
      addTearDown(container.dispose);

      await bootstrapAuthSession(container, FirebaseBootstrapResult.configured);

      expect(gateway.signInAnonymouslyCalls, 1);
      expect(gateway.currentSession?.isAnonymous, isTrue);
    },
  );

  test('anonymous creation failure does not escape bootstrap', () async {
    final gateway = BootstrapAuthGateway(failAnonymousSignIn: true);
    final container = _configuredContainer(gateway);
    addTearDown(container.dispose);

    await bootstrapAuthSession(container, FirebaseBootstrapResult.configured);

    expect(gateway.signInAnonymouslyCalls, 1);
  });

  test('unavailable Firebase never attempts anonymous creation', () async {
    final gateway = BootstrapAuthGateway();
    final container = _configuredContainer(gateway);
    addTearDown(container.dispose);

    await bootstrapAuthSession(container, FirebaseBootstrapResult.unavailable);

    expect(gateway.signInAnonymouslyCalls, 0);
  });
}

ProviderContainer _configuredContainer(BootstrapAuthGateway gateway) {
  return ProviderContainer(
    overrides: authRepositoryOverrides(
      FirebaseBootstrapResult.configured,
      authGatewayBuilder: () => gateway,
      googleGatewayBuilder: UnconfiguredGoogleSignInGateway.new,
      functionsGatewayBuilder: UnconfiguredAuthFunctionsGateway.new,
      localStateWiperBuilder: (_) => const NoopLocalStateWiper(),
    ),
  );
}

class BootstrapAuthGateway implements AuthGateway {
  BootstrapAuthGateway({this.currentSession, this.failAnonymousSignIn = false});

  @override
  AuthSession? currentSession;
  final bool failAnonymousSignIn;
  int signInAnonymouslyCalls = 0;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    signInAnonymouslyCalls += 1;
    if (failAnonymousSignIn) {
      throw const AuthGatewayException('anonymous-sign-in-failed');
    }
    currentSession = const AuthSession(uid: 'anon-created', isAnonymous: true);
    return currentSession!;
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    throw UnimplementedError();
  }

  @override
  Future<void> reauthenticateWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {}

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    currentSession = null;
  }
}
