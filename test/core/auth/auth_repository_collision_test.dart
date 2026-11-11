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
