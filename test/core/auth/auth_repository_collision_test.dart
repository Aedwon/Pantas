import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';

void main() {
  test('credential collision switches identity without progress inspection',
      () async {
    final gateway = CollisionAuthGateway();
    final wiper = RecordingLocalStateWiper();
    final functions = CountingFunctionsGateway(operations: gateway.operations);
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: functions,
      accountTransitionGateway:
          RecordingAccountTransitionGateway(gateway.operations),
      localStateWiper: wiper,
    )..beforeIdentityChange = () async {
        gateway.operations.add('clearPayment');
      };

    final result = await repo.signInWithGoogle();

    expect(gateway.operations, [
      'link',
      'prepareForAccountSwitch',
      'clearPayment',
      'signOut',
      'signInWithCredential',
      'recordSignInEvent',
    ]);
    expect(result, const SignInResult.switchedToExisting());
    expect(wiper.meaningfulProgressReads, 0);
    expect(wiper.wipeCalls, 0);
  });

  test('collision records named sign-in root after existing credential sign-in',
      () async {
    final gateway = CollisionAuthGateway();
    final functions = CountingFunctionsGateway(operations: gateway.operations);
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: functions,
      localStateWiper: RecordingLocalStateWiper(),
    );

    await repo.signInWithGoogle();

    expect(functions.recordSignInEventCalls, 1);
    expect(
      gateway.operations.indexOf('signInWithCredential'),
      lessThan(gateway.operations.indexOf('recordSignInEvent')),
    );
  });

  test('failure after anonymous sign-out re-anonymizes', () async {
    final gateway = CollisionAuthGateway(failFallbackSignIn: true);
    final wiper = RecordingLocalStateWiper();
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: CountingFunctionsGateway(),
      localStateWiper: wiper,
    );

    final result = await repo.signInWithGoogle();

    expect(result, const SignInResult.failed(reason: 'fallback-failed'));
    expect(gateway.operations, [
      'link',
      'signOut',
      'signInWithCredential',
      'signInAnonymously',
    ]);
    expect(wiper.wipeCalls, 0);
  });

  group('switching away from a real account', () {
    AuthRepository build(
      CollisionAuthGateway gateway, {
      Future<void> Function(Future<void> Function() wipe)? guard,
    }) {
      final ops = gateway.operations;
      return AuthRepository(
        gateway: gateway,
        googleGateway: OneTokenGoogleGateway(),
        functionsGateway: CountingFunctionsGateway(operations: ops),
        accountTransitionGateway: RecordingAccountTransitionGateway(ops),
        localStateWiper: OrderedWiper(ops),
      )
        ..beforeIdentityChange = () async {
          ops.add('clearPayment');
        }
        ..stopSyncForWipe = () async {
          ops.add('stopSync');
        }
        ..resumeSync = () async {
          ops.add('resumeSync');
        }
        ..signOutWipeGuard = guard ??
            (wipe) async {
              ops.add('guard-start');
              await wipe();
              ops.add('guard-end');
            };
    }

    test('sends, stops Sync, wipes once under the guard, then signs in',
        () async {
      final gateway = CollisionAuthGateway(
        session: const AuthSession(uid: 'user-a'),
      );

      final result = await build(gateway).signInWithGoogle();

      expect(gateway.operations, [
        'link',
        'prepareForAccountSwitch',
        'stopSync',
        'guard-start',
        'wipeAll',
        'guard-end',
        'clearPayment',
        'signOut',
        'signInWithCredential',
        'recordSignInEvent',
      ]);
      expect(result, const SignInResult.switchedToExisting());
    });

    test('an unsent report refuses the switch: data and Sync stay', () async {
      final gateway = CollisionAuthGateway(
        session: const AuthSession(uid: 'user-a'),
      );
      final repo = build(
        gateway,
        guard: (wipe) async {
          gateway.operations.add('guard-start');
          throw const AuthGatewayException('network-request-failed');
        },
      );

      await expectLater(
        repo.signInWithGoogle(),
        throwsA(isA<AuthGatewayException>()),
      );

      expect(gateway.operations, [
        'link',
        'prepareForAccountSwitch',
        'stopSync',
        'guard-start',
        'resumeSync',
      ]);
      expect(gateway.currentSession?.uid, 'user-a');
    });

    test('if the new account then fails to sign in, it ends as a guest',
        () async {
      final gateway = CollisionAuthGateway(
        session: const AuthSession(uid: 'user-a'),
        failFallbackSignIn: true,
      );

      final result = await build(gateway).signInWithGoogle();

      expect(result, const SignInResult.failed(reason: 'fallback-failed'));
      expect(gateway.operations.last, 'signInAnonymously');
      expect(
        gateway.operations.indexOf('wipeAll'),
        lessThan(gateway.operations.indexOf('signOut')),
      );
      expect(gateway.currentSession?.isAnonymous, isTrue);
    });

    test('a guest keeps its progress for the account it joins: no wipe',
        () async {
      final gateway = CollisionAuthGateway();
      await build(gateway).signInWithGoogle();
      expect(gateway.operations, isNot(contains('wipeAll')));
      expect(gateway.operations, isNot(contains('stopSync')));
    });
  });

  test('collision stops before signOut when switch preparation fails',
      () async {
    final gateway = CollisionAuthGateway();
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: OneTokenGoogleGateway(),
      functionsGateway: CountingFunctionsGateway(),
      accountTransitionGateway:
          FailingAccountSwitchTransitionGateway(gateway.operations),
      localStateWiper: RecordingLocalStateWiper(),
    );

    await expectLater(repo.signInWithGoogle(), throwsA(isA<StateError>()));

    expect(gateway.operations, ['link', 'prepareForAccountSwitch']);
  });
}

class CollisionAuthGateway implements AuthGateway {
  CollisionAuthGateway({
    this.failFallbackSignIn = false,
    AuthSession? session,
  }) : currentSession =
            session ?? const AuthSession(uid: 'anon-1', isAnonymous: true);

  final bool failFallbackSignIn;
  final operations = <String>[];

  @override
  AuthSession? currentSession;

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
  Future<void> reauthenticateWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {}

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
  CountingFunctionsGateway({this.operations});

  final List<String>? operations;
  int recordSignInEventCalls = 0;

  @override
  Future<void> recordSignInEvent() async {
    operations?.add('recordSignInEvent');
    recordSignInEventCalls += 1;
  }

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<Uri> exportData() async =>
      Uri.parse('https://example.com/export.json');
}

class RecordingAccountTransitionGateway implements AccountTransitionGateway {
  RecordingAccountTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {
    operations.add('prepareForAccountSwitch');
  }

  @override
  Future<void> prepareForDeleteAccount() async {}

  @override
  Future<void> prepareForSignOut() async {}
}

class FailingAccountSwitchTransitionGateway
    implements AccountTransitionGateway {
  FailingAccountSwitchTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {
    operations.add('prepareForAccountSwitch');
    throw StateError('account-switch preparation failed');
  }

  @override
  Future<void> prepareForDeleteAccount() async {}

  @override
  Future<void> prepareForSignOut() async {}
}

class RecordingLocalStateWiper implements LocalStateWiper {
  int meaningfulProgressReads = 0;
  int wipeCalls = 0;

  @override
  Future<bool> hasMeaningfulProgress() async {
    meaningfulProgressReads += 1;
    return true;
  }

  @override
  Future<void> wipeAll() async {
    wipeCalls += 1;
  }
}

class OrderedWiper implements LocalStateWiper {
  OrderedWiper(this.operations);

  final List<String> operations;

  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async {
    operations.add('wipeAll');
  }
}
