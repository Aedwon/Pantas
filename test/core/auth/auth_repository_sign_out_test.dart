import 'package:pantas/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signOut wipes local state before FirebaseAuth.signOut', () async {
    final operations = <String>[];
    final repo = AuthRepository(
      gateway: SignOutAuthGateway(operations),
      googleGateway: SignOutGoogleGateway(operations),
      localStateWiper: RecordingLocalStateWiper(operations),
    );

    await repo.signOut();

    expect(operations, [
      'wipeAll',
      'firebaseSignOut',
      'googleSignOut',
      'signInAnonymously',
    ]);
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
  SignOutGoogleGateway(this.operations);

  final List<String> operations;

  @override
  Future<GoogleAuthTokens?> signIn() async => null;

  @override
  Future<void> signOut() async {
    operations.add('googleSignOut');
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
