import 'package:pantas/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('credential-already-in-use signs out anon then signs in with credential',
      () async {
    final gateway = CollisionAuthGateway();
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: CountingFunctionsGateway(),
      localStateWiper: const MeaningfulLocalStateWiper(hasData: true),
      cloudProgressGateway: const MeaningfulCloudProgressGateway(hasData: true),
    );

    final result = await repo.signInWithGoogle();

    expect(gateway.operations, [
      'link',
      'signOut',
      'signInWithCredential',
    ]);
    expect(
      result,
      const SignInResult.switchedToExisting(
        meaningfulCloudData: true,
        meaningfulLocalData: true,
      ),
    );
  });

  test('collision calls recordSignInEvent after fallback sign-in', () async {
    final functions = CountingFunctionsGateway();
    final repo = AuthRepository(
      gateway: CollisionAuthGateway(),
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: functions,
      localStateWiper: const MeaningfulLocalStateWiper(hasData: false),
      cloudProgressGateway:
          const MeaningfulCloudProgressGateway(hasData: false),
    );

    await repo.signInWithGoogle();

    expect(functions.recordSignInEventCalls, 1);
  });

  test('failure between signOut and signInWithCredential re-anonymizes',
      () async {
    final gateway = CollisionAuthGateway(failFallbackSignIn: true);
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: CountingFunctionsGateway(),
      localStateWiper: const MeaningfulLocalStateWiper(hasData: true),
      cloudProgressGateway:
          const MeaningfulCloudProgressGateway(hasData: false),
    );

    final result = await repo.signInWithGoogle();

    expect(result, const SignInResult.failed(reason: 'fallback-failed'));
    expect(gateway.operations, [
      'link',
      'signOut',
      'signInWithCredential',
      'signInAnonymously',
    ]);
  });
}

class CollisionAuthGateway implements AuthGateway {
  CollisionAuthGateway({this.failFallbackSignIn = false});

  final bool failFallbackSignIn;
  final operations = <String>[];

  @override
  AuthSession? currentSession =
      const AuthSession(uid: 'anon-1', isAnonymous: true);

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    operations.add('signInAnonymously');
    currentSession = const AuthSession(uid: 'anon-2', isAnonymous: true);
    return currentSession!;
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    operations.add('link');
    throw const AuthGatewayException('credential-already-in-use');
  }

  @override
  Future<void> signOut() async {
    operations.add('signOut');
    currentSession = null;
  }

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    operations.add('signInWithCredential');
    if (failFallbackSignIn) {
      throw const AuthGatewayException('fallback-failed');
    }
    currentSession = const AuthSession(uid: 'user-1');
    return currentSession!;
  }
}

class OneTokenGoogleGateway implements GoogleSignInGateway {
  @override
  Future<GoogleAuthTokens?> signIn() async =>
      const GoogleAuthTokens(idToken: 'id');

  @override
  Future<void> signOut() async {}
}

class CountingFunctionsGateway implements AuthFunctionsGateway {
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

class MeaningfulLocalStateWiper implements LocalStateWiper {
  const MeaningfulLocalStateWiper({required this.hasData});

  final bool hasData;

  @override
  Future<bool> hasMeaningfulProgress() async => hasData;

  @override
  Future<void> wipeAll() async {}
}

class MeaningfulCloudProgressGateway implements CloudProgressGateway {
  const MeaningfulCloudProgressGateway({required this.hasData});

  final bool hasData;

  @override
  Future<bool> hasMeaningfulProgress(String uid) async => hasData;
}
