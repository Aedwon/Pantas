import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';

void main() {
  test('ensureAnonymous signs in when there is no current user', () async {
    final gateway = FakeAuthGateway();
    final repo = AuthRepository(gateway: gateway);

    await repo.ensureAnonymous();

    expect(gateway.signInAnonymouslyCalls, 1);
  });

  test('ensureAnonymous is no-op for an anonymous current user', () async {
    final gateway = FakeAuthGateway(
      currentSession: const AuthSession(uid: 'anon-1', isAnonymous: true),
    );
    final repo = AuthRepository(gateway: gateway);

    await repo.ensureAnonymous();

    expect(gateway.signInAnonymouslyCalls, 0);
  });

  test('ensureAnonymous is no-op for a named current user', () async {
    final gateway = FakeAuthGateway(
      currentSession: const AuthSession(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
      ),
    );
    final repo = AuthRepository(gateway: gateway);

    await repo.ensureAnonymous();

    expect(gateway.signInAnonymouslyCalls, 0);
  });

  test('authState emits anonymous after anonymous sign-in', () async {
    final gateway = FakeAuthGateway();
    final repo = AuthRepository(gateway: gateway);

    final expectation = expectLater(
      repo.authState,
      emits(const AuthState.anonymous(uid: 'anon-1')),
    );
    await repo.ensureAnonymous();

    await expectation;
  });
}

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({AuthSession? currentSession})
      : _currentSession = currentSession {
    _controller.add(currentSession);
  }

  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _currentSession;
  int signInAnonymouslyCalls = 0;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  Future<AuthSession> signInAnonymously() async {
    signInAnonymouslyCalls += 1;
    _currentSession = const AuthSession(uid: 'anon-1', isAnonymous: true);
    _controller.add(_currentSession);
    return _currentSession!;
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    throw UnimplementedError();
  }
}
