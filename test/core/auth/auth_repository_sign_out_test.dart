import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';

void main() {
  test('AC-5 payment state clears before Firebase sign-out', () async {
    final operations = <String>[];
    final gateway = SignOutAuthGateway(operations);
    final repo = AuthRepository(gateway: gateway)
      ..beforeIdentityChange = () async {
        operations.add('clearPayment');
      };
    await repo.signOut();
    expect(operations.first, 'clearPayment');
  });

  test('signOut prepares transition before wiping local state', () async {
    final operations = <String>[];
    final repo = AuthRepository(
      gateway: SignOutAuthGateway(operations),
      googleGateway: SignOutGoogleGateway(operations),
      accountTransitionGateway: RecordingAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    );

    await repo.signOut();

    expect(operations, [
      'prepareForSignOut',
      'wipeAll',
      'firebaseSignOut',
      'googleSignOut',
      'signInAnonymously',
    ]);
  });

  test('Google sign-out failure still attempts a fresh anonymous session',
      () async {
    final operations = <String>[];
    final gateway = SignOutAuthGateway(operations);
    final repo = AuthRepository(
      gateway: gateway,
      googleGateway: SignOutGoogleGateway(operations, failSignOut: true),
      accountTransitionGateway: RecordingAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    );

    await repo.signOut();

    expect(operations, [
      'prepareForSignOut',
      'wipeAll',
      'firebaseSignOut',
      'googleSignOut',
      'signInAnonymously',
    ]);
    expect(gateway.currentSession?.isAnonymous, isTrue);
  });

  test('signOut stops when transition preparation fails', () async {
    final operations = <String>[];
    final repo = AuthRepository(
      gateway: SignOutAuthGateway(operations),
      googleGateway: SignOutGoogleGateway(operations),
      accountTransitionGateway:
          FailingSignOutAccountTransitionGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    );

    await expectLater(repo.signOut(), throwsA(isA<StateError>()));

    expect(operations, ['prepareForSignOut']);
  });
}

class SignOutAuthGateway implements AuthGateway {
  SignOutAuthGateway(this.operations);

  final List<String> operations;

  @override
  AuthSession? currentSession = const AuthSession(uid: 'user-1');

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(currentSession);

  @override
  Future<AuthSession> signInAnonymously() async {
    operations.add('signInAnonymously');
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
  ) async {}

  @override
  Future<void> signOut() async {
    operations.add('firebaseSignOut');
    currentSession = null;
  }

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    throw UnimplementedError();
  }
}

class SignOutGoogleGateway implements GoogleSignInGateway {
  SignOutGoogleGateway(this.operations, {this.failSignOut = false});

  final List<String> operations;
  final bool failSignOut;

  @override
  Future<GoogleAuthTokens?> signIn() async => null;

  @override
  Future<void> signOut() async {
    operations.add('googleSignOut');
    if (failSignOut) throw StateError('google sign-out failed');
  }
}

class RecordingAccountTransitionGateway implements AccountTransitionGateway {
  RecordingAccountTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {
    operations.add('prepareForAccountSwitch');
  }

  @override
  Future<void> prepareForDeleteAccount() async {
    operations.add('prepareForDeleteAccount');
  }

  @override
  Future<void> prepareForSignOut() async {
    operations.add('prepareForSignOut');
  }
}

class FailingSignOutAccountTransitionGateway
    implements AccountTransitionGateway {
  FailingSignOutAccountTransitionGateway(this.operations);

  final List<String> operations;

  @override
  Future<void> prepareForAccountSwitch() async {}

  @override
  Future<void> prepareForDeleteAccount() async {}

  @override
  Future<void> prepareForSignOut() async {
    operations.add('prepareForSignOut');
    throw StateError('sign-out preparation failed');
  }
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
