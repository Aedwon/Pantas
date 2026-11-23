import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';

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

  test('deleteAccount reauthenticates without ordinary credential sign-in',
      () async {
    final google = PrivacyGoogleGateway();
    final gateway = PrivacyAuthGateway(
      currentSession: AuthSession(
        uid: 'user-1',
        lastSignInTime: DateTime(2026, 5, 17, 14),
      ),
    );
    final functions = PrivacyFunctionsGateway();
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: google,
      functionsGateway: functions,
      localStateWiper: const NoopLocalStateWiper(),
      clock: () => DateTime(2026, 5, 17, 14, 6),
    );

    await repo.deleteAccount();

    expect(google.signInCalls, 1);
    expect(gateway.reauthenticateCalls, 1);
    expect(gateway.googleCredentialSignInCalls, 0);
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
      accountTransitionGateway: RecordingAccountTransitionGateway(operations),
      localStateWiper: wiper,
      clock: () => DateTime(2026, 5, 17, 14, 1),
    )..beforeIdentityChange = () async {
        operations.add('clearPayment');
      };

    await repo.deleteAccount();

    expect(operations, [
      'prepareForDeleteAccount',
      'deleteAccount',
      'clearPayment',
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

  test('sign-out blocked by unsent data wipes nothing and signs nobody out',
      () async {
    final operations = <String>[];
    final gateway = PrivacyAuthGateway(
      operations: operations,
      currentSession: const AuthSession(uid: 'user-1'),
    );
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: PrivacyGoogleGateway(operations: operations),
      functionsGateway: PrivacyFunctionsGateway(operations: operations),
      accountTransitionGateway: BlockedSignOutGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    )..beforeIdentityChange = () async {
        operations.add('clearPayment');
      };

    await expectLater(
      repo.signOut(),
      throwsA(
        isA<AuthGatewayException>()
            .having((e) => e.code, 'code', 'network-request-failed'),
      ),
    );

    expect(operations, ['prepareForSignOut']);
    expect(gateway.currentSession?.uid, 'user-1');
  });

  test('online sign-out still wipes, signs out and signs in as a guest',
      () async {
    final operations = <String>[];
    final gateway = PrivacyAuthGateway(
      operations: operations,
      currentSession: const AuthSession(uid: 'user-1'),
    );
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: PrivacyGoogleGateway(operations: operations),
      functionsGateway: PrivacyFunctionsGateway(operations: operations),
      accountTransitionGateway: RecordingAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    )..beforeIdentityChange = () async {
        operations.add('clearPayment');
      };

    await repo.signOut();

    expect(operations, [
      'clearPayment',
      'wipeAll',
      'signOut',
      'googleSignOut',
      'signInAnonymously',
    ]);
  });

  test(
      'offline with nothing unsent: the wipe runs before the network step, '
      'so a retry finishes the sign-out', () async {
    // Confirmed ordering: the wipe and the local sign-out come before the
    // anonymous sign-in, which needs the network. With unsent data that can
    // no longer lose anything (the transition gateway refuses first). It
    // keeps a signed-out device free of the old account's data.
    final operations = <String>[];
    final gateway = OfflineAnonymousGateway(
      operations: operations,
      currentSession: const AuthSession(uid: 'user-1'),
    );
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: PrivacyGoogleGateway(operations: operations),
      functionsGateway: PrivacyFunctionsGateway(operations: operations),
      accountTransitionGateway: RecordingAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    );

    await expectLater(
      repo.signOut(),
      throwsA(isA<AuthGatewayException>()),
    );
    expect(operations, contains('wipeAll'));

    gateway.online = true;
    await repo.signOut();
    expect(gateway.currentSession?.isAnonymous, isTrue);
  });

  test('deleteAccount stops when transition preparation fails', () async {
    final operations = <String>[];
    final functions = PrivacyFunctionsGateway(operations: operations);
    final repo = AuthRepository(
      gateway: PrivacyAuthGateway(
        operations: operations,
        currentSession: AuthSession(
          uid: 'user-1',
          lastSignInTime: DateTime(2026, 5, 17, 14),
        ),
      ),
      googleGateway: PrivacyGoogleGateway(operations: operations),
      functionsGateway: functions,
      accountTransitionGateway:
          FailingDeleteAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
      clock: () => DateTime(2026, 5, 17, 14, 1),
    );

    await expectLater(repo.deleteAccount(), throwsA(isA<StateError>()));

    expect(operations, ['prepareForDeleteAccount']);
    expect(functions.deleteAccountCalls, 0);
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
  int reauthenticateCalls = 0;
  int googleCredentialSignInCalls = 0;

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
  Future<void> reauthenticateWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    reauthenticateCalls += 1;
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
    googleCredentialSignInCalls += 1;
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

class RecordingAccountTransitionGateway implements AccountTransitionGateway {
  RecordingAccountTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {
    operations.add('prepareForDeleteAccount');
  }

  @override
  Future<void> prepareForSignOut() async {}
}

class FailingDeleteAccountTransitionGateway
    implements AccountTransitionGateway {
  FailingDeleteAccountTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {
    operations.add('prepareForDeleteAccount');
    throw StateError('delete-account preparation failed');
  }

  @override
  Future<void> prepareForSignOut() async {}
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

class BlockedSignOutGateway implements AccountTransitionGateway {
  BlockedSignOutGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {}

  @override
  Future<void> prepareForSignOut() async {
    operations.add('prepareForSignOut');
    throw const AuthGatewayException('network-request-failed');
  }
}

class OfflineAnonymousGateway extends PrivacyAuthGateway {
  OfflineAnonymousGateway({super.operations, super.currentSession});

  bool online = false;

  @override
  Future<AuthSession> signInAnonymously() async {
    if (!online) throw const AuthGatewayException('network-request-failed');
    return super.signInAnonymously();
  }
}
