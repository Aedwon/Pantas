import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signInWithGoogle returns cancelled when picker returns null', () async {
    final repo = AuthRepository(
      gateway: FakeAuthGateway(),
      googleGateway: FakeGoogleGateway(),
      functionsGateway: FakeFunctionsGateway(),
    );

    final result = await repo.signInWithGoogle();

    expect(result, const SignInResult.cancelled());
  });

  test('signInWithGoogle links credential to current anonymous user', () async {
    final gateway = FakeAuthGateway(
      currentSession: const AuthSession(uid: 'anon-1', isAnonymous: true),
    );
    final functions = FakeFunctionsGateway();
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway:
          FakeGoogleGateway(tokens: const GoogleAuthTokens(idToken: 'id')),
      functionsGateway: functions,
    );

    final result = await repo.signInWithGoogle();

    expect(result, const SignInResult.linkedExisting());
    expect(gateway.linkCalls, 1);
    expect(functions.recordSignInEventCalls, 1);
  });

  test('signInWithGoogle returns failed with auth code on unexpected error',
      () async {
    final gateway = FakeAuthGateway(
      currentSession: const AuthSession(uid: 'anon-1', isAnonymous: true),
      linkException: const AuthGatewayException('network-request-failed'),
    );
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway:
          FakeGoogleGateway(tokens: const GoogleAuthTokens(idToken: 'id')),
      functionsGateway: FakeFunctionsGateway(),
    );

    final result = await repo.signInWithGoogle();

    expect(result, const SignInResult.failed(reason: 'network-request-failed'));
  });
}

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.currentSession, this.linkException});

  @override
  AuthSession? currentSession;
  final AuthGatewayException? linkException;
  int linkCalls = 0;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    currentSession = const AuthSession(uid: 'anon-1', isAnonymous: true);
    return currentSession!;
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    linkCalls += 1;
    if (linkException != null) throw linkException!;
    currentSession = const AuthSession(
      uid: 'anon-1',
      email: 'reader@example.com',
      displayName: 'Reader',
    );
    return currentSession!;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> signInWithGoogleCredential(
      GoogleAuthTokens tokens) async {
    currentSession = const AuthSession(uid: 'user-1');
    return currentSession!;
  }
}

class FakeGoogleGateway implements GoogleSignInGateway {
  FakeGoogleGateway({this.tokens});

  final GoogleAuthTokens? tokens;

  @override
  Future<GoogleAuthTokens?> signIn() async => tokens;

  @override
  Future<void> signOut() async {}
}

class FakeFunctionsGateway implements AuthFunctionsGateway {
  int recordSignInEventCalls = 0;

  @override
  Future<void> recordSignInEvent() async {
    recordSignInEventCalls += 1;
  }

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<Uri> exportData() async =>
      Uri.parse('https://example.com/export.json');
}
