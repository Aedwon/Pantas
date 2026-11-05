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
      firebase.ActionCodeSettings(
        url: 'https://app.test',
        handleCodeInApp: true,
      ),
    );
    registerFallbackValue(firebase.GoogleAuthProvider());
    registerFallbackValue(
      firebase.GoogleAuthProvider.credential(idToken: 'fallback-token'),
    );
  });

  test('web token changes reveal anonymous account linking', () async {
    final auth = MockFirebaseAuth();
    final anonymous = _user(uid: 'same', isAnonymous: true);
    final named = _user(uid: 'same', isAnonymous: false);
    when(auth.idTokenChanges).thenAnswer(
      (_) => Stream.fromIterable([anonymous, named]),
    );
    final sessions = await FirebaseAuthGateway(auth: auth, web: true)
        .authStateChanges
        .toList();
    expect(sessions.map((session) => session!.isAnonymous), [true, false]);
  });

  test('email links use in-app completion and preserve the UID', () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'anon', isAnonymous: true);
    final credential = MockUserCredential();
    when(() => auth.currentUser).thenReturn(user);
    when(
      () => auth.sendSignInLinkToEmail(
        email: any(named: 'email'),
        actionCodeSettings: any(named: 'actionCodeSettings'),
      ),
    ).thenAnswer((_) async {});
    when(() => user.linkWithCredential(any()))
        .thenAnswer((_) async => credential);
    final gateway = FirebaseAuthGateway(auth: auth);
    await gateway.sendLink(
      'tester@example.com',
      'https://app.test/auth/email-link',
    );
    final settings = verify(
      () => auth.sendSignInLinkToEmail(
        email: 'tester@example.com',
        actionCodeSettings: captureAny(named: 'actionCodeSettings'),
      ),
    ).captured.single as firebase.ActionCodeSettings;
    expect(settings.handleCodeInApp, isTrue);
    expect(settings.url, 'https://app.test/auth/email-link');
    await gateway.link('tester@example.com', 'https://app.test/?oobCode=test');
    final linked = verify(() => user.linkWithCredential(captureAny()))
        .captured
        .single as firebase.EmailAuthCredential;
    expect(linked.email, 'tester@example.com');
    expect(linked.emailLink, 'https://app.test/?oobCode=test');
    verifyNever(() => auth.signInWithCredential(any()));
  });

  test('Google collision reuses the credential without another popup',
      () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'anon', isAnonymous: true);
    final credential = firebase.GoogleAuthProvider.credential(
      idToken: 'existing',
    );
    final result = MockUserCredential();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.linkWithPopup(any())).thenThrow(
      firebase.FirebaseAuthException(
        code: 'credential-already-in-use',
        credential: credential,
      ),
    );
    when(() => auth.signInWithCredential(credential))
        .thenAnswer((_) async => result);
    final gateway = FirebaseAuthGateway(auth: auth);
    await expectLater(
      gateway.googlePopup(link: true),
      throwsA(isA<AuthGatewayException>()),
    );
    await gateway.googlePopup(link: false);
    verify(() => auth.signInWithCredential(credential)).called(1);
    verifyNever(() => auth.signInWithPopup(any()));
  });

  test('web Google uses Firebase popup linking', () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'anon', isAnonymous: true);
    final credential = MockUserCredential();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.linkWithPopup(any())).thenAnswer((_) async => credential);
    await FirebaseAuthGateway(auth: auth).googlePopup(link: true);
    verify(() => user.linkWithPopup(any())).called(1);
    verifyNever(() => auth.signInWithPopup(any()));
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
      isA<AuthSession>()
          .having((value) => value.uid, 'uid', 'user-1')
          .having((value) => value.isAnonymous, 'isAnonymous', false)
          .having((value) => value.email, 'email', 'reader@example.com')
          .having((value) => value.displayName, 'displayName', 'Reader')
          .having(
            (value) => value.photoUrl,
            'photoUrl',
            'https://example.com/avatar.png',
          )
          .having((value) => value.isPro, 'isPro', false)
          .having(
            (value) => value.lastSignInTime,
            'lastSignInTime',
            DateTime(2026, 8, 28, 8),
          ),
    );
  });

  test('maps auth state changes including signed-out state', () async {
    final auth = MockFirebaseAuth();
    final user = _user(uid: 'anon-1', isAnonymous: true);
    when(
      auth.authStateChanges,
    ).thenAnswer((_) => Stream<firebase.User?>.fromIterable([user, null]));

    final states = await FirebaseAuthGateway(
      auth: auth,
    ).authStateChanges.toList();

    expect(states, hasLength(2));
    expect(
      states.first,
      isA<AuthSession>()
          .having((value) => value.uid, 'uid', 'anon-1')
          .having((value) => value.isAnonymous, 'isAnonymous', true),
    );
    expect(states[1], isNull);
  });

  test('signInAnonymously returns mapped session', () async {
    final auth = MockFirebaseAuth();
    final credential = MockUserCredential();
    final user = _user(uid: 'anon-1', isAnonymous: true);
    when(() => credential.user).thenReturn(user);
    when(auth.signInAnonymously).thenAnswer((_) async => credential);

    final session = await FirebaseAuthGateway(auth: auth).signInAnonymously();

    expect(
      session,
      isA<AuthSession>()
          .having((value) => value.uid, 'uid', 'anon-1')
          .having((value) => value.isAnonymous, 'isAnonymous', true),
    );
  });

  test('signInAnonymously reports a missing credential user', () async {
    final auth = MockFirebaseAuth();
    final credential = MockUserCredential();
    when(() => credential.user).thenReturn(null);
    when(auth.signInAnonymously).thenAnswer((_) async => credential);

    await expectLater(
      FirebaseAuthGateway(auth: auth).signInAnonymously(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'missing-user-credential-result',
        ),
      ),
    );
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
    when(
      () => anonymous.linkWithCredential(any()),
    ).thenAnswer((_) async => linkedCredential);
    when(
      () => auth.signInWithCredential(any()),
    ).thenAnswer((_) async => signedInCredential);

    final gateway = FirebaseAuthGateway(auth: auth);
    const tokens = GoogleAuthTokens(
      idToken: 'google-id-token',
      accessToken: 'google-access-token',
    );

    expect(
      await gateway.linkWithGoogleCredential(tokens),
      isA<AuthSession>().having((value) => value.uid, 'uid', 'user-1'),
    );
    expect(
      await gateway.signInWithGoogleCredential(tokens),
      isA<AuthSession>().having((value) => value.uid, 'uid', 'user-1'),
    );
    verify(() => anonymous.linkWithCredential(any())).called(1);
    verify(() => auth.signInWithCredential(any())).called(1);
  });

  test('forwards FirebaseAuthException code unchanged', () async {
    final auth = MockFirebaseAuth();
    when(
      auth.signInAnonymously,
    ).thenThrow(firebase.FirebaseAuthException(code: 'network-request-failed'));

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
    when(
      () => user.reauthenticateWithCredential(any()),
    ).thenAnswer((_) async => credential);

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
