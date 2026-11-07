import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';
import 'package:pantas/core/auth/firebase_auth_gateway.dart';
import 'package:pantas/core/auth/sign_in_result.dart';

import 'firebase_auth_functions_gateway_test.dart'
    show RecordingFunctionsClient;

class _Auth extends Mock implements AuthGateway {}

class _Popup extends Mock implements GooglePopupAuthGateway {}

class _Exchange extends Mock implements GoogleAccountExchangeGateway {}

class _Token extends Mock implements CustomTokenAuthGateway {}

class _Functions extends Mock implements AuthFunctionsGateway {}

class _Transition extends Mock implements AccountTransitionGateway {}

class _FirebaseAuth extends Mock implements firebase.FirebaseAuth {}

class _FirebaseUser extends Mock implements firebase.User {}

const _anonymous = AuthSession(uid: 'anon', isAnonymous: true);

String _token(String uid) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part({'uid': uid})}.signature';
}

// The constructor is protected for the plugin; a test needs one.
// ignore: invalid_use_of_protected_member
FirebaseFunctionsException _functionsError(String code) =>
    // ignore: invalid_use_of_protected_member
    FirebaseFunctionsException(message: code, code: code);

void main() {
  group('repository: Google address that already has an account', () {
    late _Auth auth;
    late _Popup popup;
    late _Exchange exchange;
    late _Token token;
    late _Functions functions;
    late _Transition transition;
    late AuthRepository repository;

    setUp(() {
      auth = _Auth();
      popup = _Popup();
      exchange = _Exchange();
      token = _Token();
      functions = _Functions();
      transition = _Transition();
      when(() => auth.currentSession).thenReturn(_anonymous);
      when(() => auth.signOut()).thenAnswer((_) async {});
      when(() => auth.signInAnonymously()).thenAnswer((_) async => _anonymous);
      when(() => functions.recordSignInEvent()).thenAnswer((_) async {});
      when(() => transition.prepareForAccountSwitch()).thenAnswer((_) async {});
      when(() => token.signInWithCustomToken(any())).thenAnswer((_) async {});
      repository = AuthRepository(
        gateway: auth,
        googlePopupGateway: popup,
        googleExchangeGateway: exchange,
        customTokenGateway: token,
        functionsGateway: functions,
        accountTransitionGateway: transition,
      );
    });

    test(
        'signs in through the exchange and a custom token, with no second '
        'pop-up', () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const GoogleAccountExistsException('google-id'));
      when(() => exchange.exchange('google-id'))
          .thenAnswer((_) async => 'custom-token');

      final result = await repository.signInWithGoogle();

      expect(result, const SignInResult.switchedToExisting());
      verifyInOrder([
        () => popup.googlePopup(link: true),
        // The exchange needs the anonymous caller, so it runs before sign out.
        () => exchange.exchange('google-id'),
        () => transition.prepareForAccountSwitch(),
        () => auth.signOut(),
        () => token.signInWithCustomToken('custom-token'),
        () => functions.recordSignInEvent(),
      ]);
      verifyNever(() => popup.googlePopup(link: false));
    });

    test('credential-already-in-use keeps the pending credential path',
        () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const AuthGatewayException('credential-already-in-use'));
      when(() => popup.googlePopup(link: false)).thenAnswer((_) async {});

      final result = await repository.signInWithGoogle();

      expect(result, const SignInResult.switchedToExisting());
      verifyInOrder([
        () => popup.googlePopup(link: true),
        () => auth.signOut(),
        () => popup.googlePopup(link: false),
        () => functions.recordSignInEvent(),
      ]);
      verifyNever(() => exchange.exchange(any()));
      verifyNever(() => token.signInWithCustomToken(any()));
    });

    test('a refused exchange fails and leaves the anonymous session alone',
        () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const GoogleAccountExistsException('google-id'));
      when(() => exchange.exchange(any()))
          .thenThrow(const AuthGatewayException('permission-denied'));

      final result = await repository.signInWithGoogle();

      expect(result, const SignInResult.failed(reason: 'permission-denied'));
      verifyNever(() => auth.signOut());
      verifyNever(() => auth.signInAnonymously());
      verifyNever(() => token.signInWithCustomToken(any()));
      verifyNever(() => functions.recordSignInEvent());
    });

    test('a custom token Firebase refuses fails and returns to anonymous',
        () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const GoogleAccountExistsException('google-id'));
      when(() => exchange.exchange(any())).thenAnswer((_) async => 'custom');
      when(() => token.signInWithCustomToken(any()))
          .thenThrow(const AuthGatewayException('invalid-custom-token'));
      var signedOut = false;
      when(() => auth.signOut()).thenAnswer((_) async => signedOut = true);
      when(() => auth.currentSession)
          .thenAnswer((_) => signedOut ? null : _anonymous);

      final result = await repository.signInWithGoogle();

      expect(result, const SignInResult.failed(reason: 'invalid-custom-token'));
      verify(() => auth.signInAnonymously()).called(1);
      verifyNever(() => functions.recordSignInEvent());
    });

    test('without an exchange or token gateway it fails as today', () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const GoogleAccountExistsException('google-id'));
      final bare = AuthRepository(gateway: auth, googlePopupGateway: popup);

      final result = await bare.signInWithGoogle();

      expect(result, isA<FailedSignInResult>());
      verifyNever(() => auth.signOut());
    });

    test('closing the pop-up still counts as cancelled', () async {
      when(() => popup.googlePopup(link: true))
          .thenThrow(const AuthGatewayException('popup-closed-by-user'));

      expect(
        await repository.signInWithGoogle(),
        const SignInResult.cancelled(),
      );
      verifyNever(() => exchange.exchange(any()));
    });

    group('an exchange result that arrives late', () {
      late Completer<String> server;

      setUp(() {
        server = Completer<String>();
        when(() => popup.googlePopup(link: true))
            .thenThrow(const GoogleAccountExistsException('google-id'));
        when(() => exchange.exchange('google-id'))
            .thenAnswer((_) => server.future);
      });

      Future<SignInResult> startAndWait() async {
        final result = repository.signInWithGoogle();
        await Future<void>.delayed(Duration.zero);
        verify(() => exchange.exchange('google-id')).called(1);
        return result;
      }

      void expectUntouched() {
        verifyNever(() => transition.prepareForAccountSwitch());
        verifyNever(() => auth.signOut());
        verifyNever(() => auth.signInAnonymously());
        verifyNever(() => token.signInWithCustomToken(any()));
        verifyNever(() => functions.recordSignInEvent());
      }

      test('is dropped when the flow was cancelled meanwhile', () async {
        final result = startAndWait();
        await Future<void>.delayed(Duration.zero);
        repository.cancelVerification();
        server.complete(_token('maria'));

        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('is dropped when a newer sign-in was asked for meanwhile', () async {
        final result = startAndWait();
        await Future<void>.delayed(Duration.zero);
        // A second request bumps the identity epoch and queues behind us.
        unawaited(repository.signOut().catchError((Object _) {}));
        server.complete(_token('maria'));

        expect(await result, const SignInResult.cancelled());
        verifyNever(() => token.signInWithCustomToken(any()));
        verifyNever(() => functions.recordSignInEvent());
      });

      test('is dropped when the owner changed in another tab', () async {
        final result = startAndWait();
        await Future<void>.delayed(Duration.zero);
        when(() => auth.currentSession).thenReturn(
          const AuthSession(uid: 'tab-two', email: 'z@y.co'),
        );
        server.complete(_token('maria'));

        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('is dropped when the session ended in another tab', () async {
        final result = startAndWait();
        await Future<void>.delayed(Duration.zero);
        when(() => auth.currentSession).thenReturn(null);
        server.complete(_token('maria'));

        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('still signs in when nothing changed', () async {
        final result = startAndWait();
        await Future<void>.delayed(Duration.zero);
        server.complete(_token('maria'));

        expect(await result, const SignInResult.switchedToExisting());
        verifyInOrder([
          () => transition.prepareForAccountSwitch(),
          () => auth.signOut(),
          () => token.signInWithCustomToken(any()),
          () => functions.recordSignInEvent(),
        ]);
      });

      group('and the flow is cancelled during the token sign-in', () {
        late Completer<void> tokenSignIn;
        late AuthSession? session;

        setUp(() {
          tokenSignIn = Completer<void>();
          session = _anonymous;
          when(() => auth.currentSession).thenAnswer((_) => session);
          when(() => auth.signOut()).thenAnswer((_) async => session = null);
          when(() => auth.signInAnonymously()).thenAnswer((_) async {
            return session = _anonymous;
          });
        });

        test('signs the installed account out and returns to anonymous',
            () async {
          when(() => token.signInWithCustomToken(any())).thenAnswer((_) async {
            await tokenSignIn.future;
            session = const AuthSession(uid: 'maria', email: 'm@gmail.com');
          });
          final result = startAndWait();
          server.complete(_token('maria'));
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
          verify(() => token.signInWithCustomToken(any())).called(1);
          repository.cancelVerification();
          tokenSignIn.complete();

          expect(await result, const SignInResult.cancelled());
          expect(session?.isAnonymous, isTrue);
          verify(() => auth.signOut()).called(2);
          verifyNever(() => functions.recordSignInEvent());
        });

        test('leaves another user alone if it is not the account installed',
            () async {
          when(() => token.signInWithCustomToken(any())).thenAnswer((_) async {
            await tokenSignIn.future;
            session = const AuthSession(uid: 'tab-two', email: 'z@y.co');
          });
          final result = startAndWait();
          server.complete(_token('maria'));
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
          repository.cancelVerification();
          tokenSignIn.complete();

          expect(await result, const SignInResult.cancelled());
          expect(session?.uid, 'tab-two');
          verify(() => auth.signOut()).called(1);
          verifyNever(() => auth.signInAnonymously());
          verifyNever(() => functions.recordSignInEvent());
        });
      });
    });
  });

  group('FirebaseGoogleAccountExchangeGateway', () {
    test('sends only the ID token to the exchange callable', () async {
      final client = RecordingFunctionsClient(
        responses: {
          'exchangeGoogleSignIn': {'token': 'custom-token'},
        },
      );

      final token = await FirebaseGoogleAccountExchangeGateway(client: client)
          .exchange('google-id');

      expect(token, 'custom-token');
      expect(client.calls.single.name, 'exchangeGoogleSignIn');
      expect(client.calls.single.region, 'asia-southeast1');
      expect(client.calls.single.data, {'idToken': 'google-id'});
    });

    test('a refusal becomes the callable error code', () async {
      final client = RecordingFunctionsClient(
        error: _functionsError('permission-denied'),
      );

      await expectLater(
        FirebaseGoogleAccountExchangeGateway(client: client).exchange('x'),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'permission-denied'),
        ),
      );
    });

    test('an answer without a token is malformed', () async {
      for (final answer in [
        null,
        <String, Object?>{},
        'x',
        {'token': ''},
      ]) {
        final client = RecordingFunctionsClient(
          responses: {'exchangeGoogleSignIn': answer},
        );
        await expectLater(
          FirebaseGoogleAccountExchangeGateway(client: client).exchange('x'),
          throwsA(
            isA<AuthGatewayException>()
                .having((e) => e.code, 'code', 'malformed-exchange-response'),
          ),
          reason: '$answer',
        );
      }
    });
  });

  group('FirebaseAuthGateway.googlePopup collisions', () {
    late _FirebaseAuth auth;
    late _FirebaseUser user;

    setUpAll(() {
      registerFallbackValue(firebase.GoogleAuthProvider());
    });

    setUp(() {
      auth = _FirebaseAuth();
      user = _FirebaseUser();
      when(() => auth.currentUser).thenReturn(user);
    });

    firebase.OAuthCredential google(String idToken) =>
        firebase.GoogleAuthProvider.credential(idToken: idToken);

    test('email-already-in-use on linking surfaces the Google ID token',
        () async {
      when(() => user.linkWithPopup(any())).thenThrow(
        firebase.FirebaseAuthException(
          code: 'email-already-in-use',
          credential: google('google-id'),
        ),
      );

      await expectLater(
        FirebaseAuthGateway(auth: auth).googlePopup(link: true),
        throwsA(
          isA<GoogleAccountExistsException>()
              .having((e) => e.code, 'code', 'google-account-exists')
              .having((e) => e.idToken, 'idToken', 'google-id'),
        ),
      );
    });

    test('account-exists-with-different-credential surfaces it on sign-in',
        () async {
      when(() => auth.signInWithPopup(any())).thenThrow(
        firebase.FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          credential: google('google-id'),
        ),
      );

      await expectLater(
        FirebaseAuthGateway(auth: auth).googlePopup(link: false),
        throwsA(
          isA<GoogleAccountExistsException>()
              .having((e) => e.idToken, 'idToken', 'google-id'),
        ),
      );
    });

    test('without a Google ID token the error stays a plain code', () async {
      final credentials = <firebase.AuthCredential?>[
        null,
        firebase.GoogleAuthProvider.credential(accessToken: 'access-only'),
        firebase.OAuthProvider('github.com').credential(idToken: 'other'),
      ];
      for (final credential in credentials) {
        when(() => user.linkWithPopup(any())).thenThrow(
          firebase.FirebaseAuthException(
            code: 'email-already-in-use',
            credential: credential,
          ),
        );

        await expectLater(
          FirebaseAuthGateway(auth: auth).googlePopup(link: true),
          throwsA(
            isA<AuthGatewayException>()
                .having((e) => e.code, 'code', 'email-already-in-use')
                .having(
                  (e) => e is GoogleAccountExistsException,
                  'typed',
                  isFalse,
                ),
          ),
        );
      }
    });

    test('the token is kept out of the exception text', () {
      const error = GoogleAccountExistsException('secret-google-id');

      expect(error.toString(), isNot(contains('secret-google-id')));
    });

    test('credential-already-in-use is not turned into the typed error',
        () async {
      when(() => user.linkWithPopup(any())).thenThrow(
        firebase.FirebaseAuthException(
          code: 'credential-already-in-use',
          credential: google('google-id'),
        ),
      );

      await expectLater(
        FirebaseAuthGateway(auth: auth).googlePopup(link: true),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'credential-already-in-use'),
        ),
      );
    });
  });
}
