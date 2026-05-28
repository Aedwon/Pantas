import 'package:cse_cet_reviewer/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const staleReauthCancelledTestName =
      'deleteAccount stops before callable when reauth is cancelled and auth '
      'is stale';

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

  test(
      'deleteAccount signs out to a fresh anonymous session after callable '
      'and local wipe', () async {
    final operations = <String>[];
    final gateway = PrivacyAuthGateway(
      operations: operations,
      currentSession: AuthSession(
        uid: 'user-1',
        lastSignInTime: DateTime(2026, 5, 17, 14),
      ),
    );
    final functions = PrivacyFunctionsGateway(operations: operations);
    final wiper = RecordingLocalStateWiper(operations);
    final google = PrivacyGoogleGateway(operations: operations);
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: google,
      functionsGateway: functions,
      localStateWiper: wiper,
      clock: () => DateTime(2026, 5, 17, 14, 1),
    );

    await repo.deleteAccount();

    expect(operations, [
      'deleteAccount',
      'wipeAll',
      'signOut',
      'googleSignOut',
      'signInAnonymously',
    ]);
    expect(
      gateway.currentSession,
      const AuthSession(uid: 'anon-1', isAnonymous: true),
    );
  });

  test(staleReauthCancelledTestName, () async {
    final functions = PrivacyFunctionsGateway();
    final repo = AuthRepository(
      gateway: PrivacyAuthGateway(
        currentSession: AuthSession(
          uid: 'user-1',
          lastSignInTime: DateTime(2026, 5, 17, 14),
        ),
      ),
      googleGateway: PrivacyGoogleGateway(tokens: null),
      functionsGateway: functions,
      localStateWiper: const NoopLocalStateWiper(),
      clock: () => DateTime(2026, 5, 17, 14, 6),
    );

    expect(
      repo.deleteAccount,
      throwsA(
        isA<AuthGatewayException>()
            .having((error) => error.code, 'code', 'requires-recent-login'),
      ),
    );
    expect(functions.deleteAccountCalls, 0);
  });
}

class PrivacyAuthGateway implements AuthGateway {
  PrivacyAuthGateway({AuthSession? currentSession, List<String>? operations})
      : currentSession = currentSession ?? const AuthSession(uid: 'user-1'),
        _operations = operations;

  final List<String>? _operations;

  @override
  AuthSession? currentSession;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    _operations?.add('signInAnonymously');
    currentSession = const AuthSession(uid: 'anon-1', isAnonymous: true);
    return currentSession!;
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    _operations?.add('signOut');
    currentSession = null;
  }

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    currentSession = const AuthSession(uid: 'user-1');
    return currentSession!;
  }
}

class PrivacyGoogleGateway implements GoogleSignInGateway {
  PrivacyGoogleGateway({
    this.tokens = const GoogleAuthTokens(idToken: 'fresh'),
    List<String>? operations,
  }) : _operations = operations;

  final GoogleAuthTokens? tokens;
  final List<String>? _operations;
  int signInCalls = 0;

  @override
  Future<GoogleAuthTokens?> signIn() async {
    signInCalls += 1;
    return tokens;
  }

  @override
  Future<void> signOut() async {
    _operations?.add('googleSignOut');
  }
}

class PrivacyFunctionsGateway implements AuthFunctionsGateway {
  PrivacyFunctionsGateway({List<String>? operations})
      : _operations = operations;

  final List<String>? _operations;
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
    _operations?.add('deleteAccount');
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

class RecordingLocalStateWiper implements LocalStateWiper {
  RecordingLocalStateWiper(this.operations);

  final List<String> operations;

  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async {
    operations.add('wipeAll');
  }
}
