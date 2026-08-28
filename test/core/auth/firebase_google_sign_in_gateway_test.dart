import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/firebase_google_sign_in_gateway.dart';

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  test('initializes exactly once and returns only the ID token', () async {
    final account = MockGoogleSignInAccount();
    when(() => account.authentication).thenReturn(
      const GoogleSignInAuthentication(idToken: 'google-id-token'),
    );
    final client = RecordingGoogleSignInClient(account: account);
    final gateway = FirebaseGoogleSignInGateway(client: client);

    final first = await gateway.signIn();
    final second = await gateway.signIn();

    expect(client.initializeCalls, 1);
    expect(client.authenticateCalls, 2);
    expect(first?.idToken, 'google-id-token');
    expect(first?.accessToken, isNull);
    expect(second?.idToken, 'google-id-token');
  });

  test('maps only explicit cancellation to null', () async {
    final client = RecordingGoogleSignInClient(
      authenticateError: const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      ),
    );

    expect(
      await FirebaseGoogleSignInGateway(client: client).signIn(),
      isNull,
    );
  });

  test('keeps non-cancel Google errors as failures', () async {
    final client = RecordingGoogleSignInClient(
      authenticateError: const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      ),
    );

    await expectLater(
      FirebaseGoogleSignInGateway(client: client).signIn(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'google-sign-in-clientConfigurationError',
        ),
      ),
    );
  });

  test('fails when Google does not return an ID token', () async {
    final account = MockGoogleSignInAccount();
    when(() => account.authentication).thenReturn(
      const GoogleSignInAuthentication(idToken: null),
    );
    final client = RecordingGoogleSignInClient(account: account);

    await expectLater(
      FirebaseGoogleSignInGateway(client: client).signIn(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'missing-google-id-token',
        ),
      ),
    );
  });

  test('ordinary sign-out initializes then calls signOut only', () async {
    final client = RecordingGoogleSignInClient();
    final gateway = FirebaseGoogleSignInGateway(client: client);

    await gateway.signOut();
    await gateway.signOut();

    expect(client.initializeCalls, 1);
    expect(client.signOutCalls, 2);
    expect(client.authenticateCalls, 0);
  });
}

class RecordingGoogleSignInClient implements GoogleSignInClient {
  RecordingGoogleSignInClient({this.account, this.authenticateError});

  final GoogleSignInAccount? account;
  final Object? authenticateError;
  int initializeCalls = 0;
  int authenticateCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<GoogleSignInAccount> authenticate() async {
    authenticateCalls += 1;
    if (authenticateError case final error?) throw error;
    final value = account;
    if (value == null) throw StateError('No account configured');
    return value;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}
