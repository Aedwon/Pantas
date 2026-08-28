import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';

class MockFirebaseAuth extends Mock implements firebase.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase.User {}

class MockUserCredential extends Mock implements firebase.UserCredential {}

class MockUserMetadata extends Mock implements firebase.UserMetadata {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      firebase.GoogleAuthProvider.credential(idToken: 'fallback-token'),
    );
  });

  test('maps current Firebase user to AuthSession', () {
    final auth = MockFirebaseAuth();
    final user = _user(
      uid: 'user-1',
      isAnonymous: false,
      email: 'reader@example.com',
      displayName: 'Reader',
      photoUrl: 'https://example.com/avatar.png',
      lastSignInTime: DateTime(2026, 8, 28, 8),
    );
    when(() => auth.currentUser).thenReturn(user);

    final session = FirebaseAuthGateway(auth: auth).currentSession;

    expect(
      session,
      AuthSession(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
        photoUrl: 'https://example.com/avatar.png',
        isPro: false,
        lastSignInTime: DateTime(2026, 8, 28, 8),
      ),
    );
  });

  test('maps auth state changes including signed-out state', () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'anon-1', isAnonymous: true);
    when(() => auth.authStateChanges())
        .thenAnswer((_) => Stream<firebase.User?>.fromIterable([user, null]));

    final states = await FirebaseAuthGateway(auth: auth).authStateChanges.toList();

    expect(states, [
      const AuthSession(uid: 'anon-1', isAnonymous: true),
      null,
    ]);
  });

  test('signInAnonymously returns mapped session', () async {
    final auth = MockFirebaseAuth();
    final credential = MockUserCredential();
    final user = _user(uid: 'anon-1', isAnonymous: true);
    when(() => credential.user).thenReturn(user);
    when(() => auth.signInAnonymously()).thenAnswer((_) async => credential);

    final session = await FirebaseAuthGateway(auth: auth).signInAnonymously();

    expect(session, const AuthSession(uid: 'anon-1', isAnonymous: true));
  });

  test('links and signs in with Google credentials', () async {
    final auth = MockFirebaseAuth();
    final anonymous = _user(uid: 'anon-1', isAnonymous: true);
    final named = _user(
      uid: 'user-1',
      isAnonymous: false,
      email: 'reader@example.com',
    );
    final linkedCredential = MockUserCredential();
    final signedInCredential = MockUserCredential();
    when(() => auth.currentUser).thenReturn(anonymous);
    when(() => linkedCredential.user).thenReturn(named);
    when(() => signedInCredential.user).thenReturn(named);
    when(() => anonymous.linkWithCredential(any()))
        .thenAnswer((_) async => linkedCredential);
    when(() => auth.signInWithCredential(any()))
        .thenAnswer((_) async => signedInCredential);

    final gateway = FirebaseAuthGateway(auth: auth);
    const tokens = GoogleAuthTokens(
      idToken: 'google-id-token',
      accessToken: 'google-access-token',
    );

    expect(await gateway.linkWithGoogleCredential(tokens),
        isA<AuthSession>().having((value) => value.uid, 'uid', 'user-1'));
    expect(await gateway.signInWithGoogleCredential(tokens),
        isA<AuthSession>().having((value) => value.uid, 'uid', 'user-1'));
    verify(() => anonymous.linkWithCredential(any())).called(1);
    verify(() => auth.signInWithCredential(any())).called(1);
  });

  test('forwards FirebaseAuthException code unchanged', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.signInAnonymously()).thenThrow(
      firebase.FirebaseAuthException(code: 'network-request-failed'),
    );

    await expectLater(
      FirebaseAuthGateway(auth: auth).signInAnonymously(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'network-request-failed',
        ),
      ),
    );
  });

  test('link and reauthentication require a current user', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);
    final gateway = FirebaseAuthGateway(auth: auth);
    const tokens = GoogleAuthTokens(idToken: 'google-id-token');

    await expectLater(
      gateway.linkWithGoogleCredential(tokens),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'missing-current-user',
        ),
      ),
    );
    await expectLater(
      gateway.reauthenticateWithGoogleCredential(tokens),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'missing-current-user',
        ),
      ),
    );
  });

  test('reauthenticates current user with Google credential', () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'user-1', isAnonymous: false);
    final credential = MockUserCredential();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.reauthenticateWithCredential(any()))
        .thenAnswer((_) async => credential);

    await FirebaseAuthGateway(auth: auth).reauthenticateWithGoogleCredential(
      const GoogleAuthTokens(idToken: 'fresh-google-id-token'),
    );

    verify(() => user.reauthenticateWithCredential(any())).called(1);
    verifyNever(() => auth.signInWithCredential(any()));
  });
}

MockFirebaseUser _user({
  required String uid,
  required bool isAnonymous,
  String? email,
  String? displayName,
  String? photoUrl,
  DateTime? lastSignInTime,
}) {
  final user = MockFirebaseUser();
  final metadata = MockUserMetadata();
  when(() => user.uid).thenReturn(uid);
  when(() => user.isAnonymous).thenReturn(isAnonymous);
  when(() => user.email).thenReturn(email);
  when(() => user.displayName).thenReturn(displayName);
  when(() => user.photoURL).thenReturn(photoUrl);
  when(() => user.metadata).thenReturn(metadata);
  when(() => metadata.lastSignInTime).thenReturn(lastSignInTime);
  return user;
}
