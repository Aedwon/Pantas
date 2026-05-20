import 'package:cse_cet_reviewer/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exportData calls exportData callable and returns a Uri', () async {
    final functions = PrivacyFunctionsGateway();
    final repo = AuthRepository(
      gateway: PrivacyAuthGateway(),
      functionsGateway: functions,
    );

    final uri = await repo.exportData();

    expect(uri, Uri.parse('https://example.com/export.json'));
    expect(functions.exportDataCalls, 1);
  });

  test('deleteAccount reauthenticates for stale sign-in', () async {
    final google = PrivacyGoogleGateway();
    final functions = PrivacyFunctionsGateway();
    final repo = AuthRepository(
      gateway: PrivacyAuthGateway(
        currentSession: AuthSession(
          uid: 'user-1',
          lastSignInTime: DateTime(2026, 5, 17, 14),
        ),
      ),
      googleGateway: google,
      functionsGateway: functions,
      localStateWiper: const NoopLocalStateWiper(),
      clock: () => DateTime(2026, 5, 17, 14, 6),
    );

    await repo.deleteAccount();

    expect(google.signInCalls, 1);
    expect(functions.deleteAccountCalls, 1);
  });
}

class PrivacyAuthGateway implements AuthGateway {
  PrivacyAuthGateway({AuthSession? currentSession})
      : currentSession = currentSession ?? const AuthSession(uid: 'user-1');

  @override
  AuthSession? currentSession;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async =>
      const AuthSession(uid: 'anon-1');

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
    currentSession = const AuthSession(uid: 'user-1');
    return currentSession!;
  }
}

class PrivacyGoogleGateway implements GoogleSignInGateway {
  int signInCalls = 0;

  @override
  Future<GoogleAuthTokens?> signIn() async {
    signInCalls += 1;
    return const GoogleAuthTokens(idToken: 'fresh');
  }

  @override
  Future<void> signOut() async {}
}

class PrivacyFunctionsGateway implements AuthFunctionsGateway {
  int exportDataCalls = 0;
  int deleteAccountCalls = 0;

  @override
  Future<void> recordSignInEvent() async {}

  @override
  Future<Uri> exportData() async {
    exportDataCalls += 1;
    return Uri.parse('https://example.com/export.json');
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalls += 1;
  }
}

class NoopLocalStateWiper implements LocalStateWiper {
  const NoopLocalStateWiper();

  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async {}
}
