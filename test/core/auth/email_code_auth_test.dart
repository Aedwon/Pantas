import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/sign_in_result.dart';

import 'firebase_auth_functions_gateway_test.dart'
    show RecordingFunctionsClient;

class _Auth extends Mock implements AuthGateway {}

class _Codes extends Mock implements EmailCodeGateway {}

class _Token extends Mock implements CustomTokenAuthGateway {}

class _Transition extends Mock implements AccountTransitionGateway {}

class _Functions extends Mock implements AuthFunctionsGateway {}

String _token(String uid) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part({'uid': uid})}.signature';
}

FirebaseFunctionsException _error(String code, {Object? details}) =>
    // The constructor is protected for the plugin; a test needs one.
    // ignore: invalid_use_of_protected_member
    FirebaseFunctionsException(message: code, code: code, details: details);

class _Throwing extends RecordingFunctionsClient {
  _Throwing(this.thrown);
  final FirebaseFunctionsException thrown;

  @override
  Future<Object?> call({
    required String region,
    required String name,
    Object? data,
  }) async {
    throw thrown;
  }
}

void main() {
  group('FirebaseEmailCodeGateway', () {
    test('requests a code from the beta region and returns the wait', () async {
      final client = RecordingFunctionsClient(
        responses: {
          'requestSignInCode': {'resendAfterSeconds': 42},
        },
      );
      final seconds = await FirebaseEmailCodeGateway(
        client: client,
      ).requestCode('juan@gmail.com');
      expect(seconds, 42);
      expect(client.calls.single.name, 'requestSignInCode');
      expect(client.calls.single.region, 'asia-southeast1');
      expect(client.calls.single.data, {'email': 'juan@gmail.com'});
    });

    test('verifies a code and returns the token', () async {
      final client = RecordingFunctionsClient(
        responses: {
          'verifySignInCode': {'token': 'abc'},
        },
      );
      final token = await FirebaseEmailCodeGateway(
        client: client,
      ).verifyCode('juan@gmail.com', '482139');
      expect(token, 'abc');
      expect(client.calls.single.name, 'verifySignInCode');
      expect(client.calls.single.data, {
        'email': 'juan@gmail.com',
        'code': '482139',
      });
    });

    test('a malformed answer is unavailable', () async {
      for (final response in [null, <String, Object?>{}, 'x']) {
        await expectLater(
          FirebaseEmailCodeGateway(
            client: RecordingFunctionsClient(
              responses: {
                'requestSignInCode': response,
                'verifySignInCode': response,
              },
            ),
          ).requestCode('a@b.co'),
          throwsA(
            isA<EmailCodeException>().having(
              (e) => e.failure,
              'failure',
              EmailCodeFailure.unavailable,
            ),
          ),
        );
      }
    });

    test('maps each server answer to a failure', () async {
      Future<EmailCodeException> catchFrom(
        String code, {
        Object? details,
        bool verify = true,
      }) async {
        final gateway = FirebaseEmailCodeGateway(
          client: _Throwing(_error(code, details: details)),
        );
        try {
          await (verify
              ? gateway.verifyCode('a@b.co', '123456')
              : gateway.requestCode('a@b.co'));
        } on EmailCodeException catch (error) {
          return error;
        }
        fail('no exception');
      }

      final wrong = await catchFrom(
        'invalid-argument',
        details: {'reason': 'wrong', 'triesLeft': 3},
      );
      expect(wrong.failure, EmailCodeFailure.wrong);
      expect(wrong.triesLeft, 3);
      expect(
        (await catchFrom('not-found', details: {'reason': 'expired'})).failure,
        EmailCodeFailure.expired,
      );
      expect(
        (await catchFrom(
          'resource-exhausted',
          details: {'reason': 'tooManyTries'},
        ))
            .failure,
        EmailCodeFailure.tooManyTries,
      );
      expect(
        (await catchFrom('resource-exhausted')).failure,
        EmailCodeFailure.rateLimited,
      );
      expect(
        (await catchFrom('resource-exhausted', verify: false)).failure,
        EmailCodeFailure.tooManyRequests,
      );
      expect(
        (await catchFrom('invalid-argument', verify: false)).failure,
        EmailCodeFailure.invalidEmail,
      );
      expect(
        (await catchFrom('permission-denied')).failure,
        EmailCodeFailure.disabled,
      );
      for (final code in ['unavailable', 'unauthenticated', 'internal']) {
        expect(
          (await catchFrom(code)).failure,
          EmailCodeFailure.unavailable,
          reason: code,
        );
      }
    });
  });

  test('customTokenUid reads the uid and rejects anything else', () {
    expect(customTokenUid(_token('abc')), 'abc');
    expect(customTokenUid('nope'), isNull);
    expect(customTokenUid('a.@@@.c'), isNull);
    expect(
      customTokenUid('a.${base64Url.encode(utf8.encode('[]'))}.c'),
      isNull,
    );
  });

  group('AuthRepository email code', () {
    late _Auth auth;
    late _Codes codes;
    late _Token custom;
    late _Transition transition;
    late _Functions functions;
    late AuthRepository repository;
    late List<String> identityChanges;

    setUp(() {
      auth = _Auth();
      codes = _Codes();
      custom = _Token();
      transition = _Transition();
      functions = _Functions();
      identityChanges = [];
      repository = AuthRepository(
        gateway: auth,
        emailCodeGateway: codes,
        customTokenGateway: custom,
        accountTransitionGateway: transition,
        functionsGateway: functions,
      )..beforeIdentityChange = () async => identityChanges.add('before');
      when(() => auth.currentSession).thenReturn(
        const AuthSession(uid: 'anon', isAnonymous: true),
      );
      when(() => custom.signInWithCustomToken(any())).thenAnswer((_) async {});
      when(() => transition.prepareForAccountSwitch()).thenAnswer((_) async {});
      when(() => functions.recordSignInEvent()).thenAnswer((_) async {});
      when(() => auth.signOut()).thenAnswer((_) async {});
    });

    test('requesting trims and lowercases the email', () async {
      when(() => codes.requestCode(any())).thenAnswer((_) async => 60);
      expect(await repository.requestCode(' Juan@Gmail.COM '), 60);
      verify(() => codes.requestCode('juan@gmail.com')).called(1);
    });

    test('a token for the anonymous uid signs in without a switch', () async {
      final token = _token('anon');
      when(() => codes.verifyCode(any(), any())).thenAnswer((_) async => token);
      expect(
        await repository.verifyCode('Juan@Gmail.com', '482139'),
        const SignInResult.linkedExisting(),
      );
      verify(() => codes.verifyCode('juan@gmail.com', '482139')).called(1);
      verify(() => custom.signInWithCustomToken(token)).called(1);
      verify(() => functions.recordSignInEvent()).called(1);
      verifyNever(() => auth.signOut());
      verifyNever(() => transition.prepareForAccountSwitch());
      expect(identityChanges, isEmpty);
    });

    test('a token for another account runs the account switch', () async {
      final token = _token('other');
      when(() => codes.verifyCode(any(), any())).thenAnswer((_) async => token);
      expect(
        await repository.verifyCode('juan@gmail.com', '482139'),
        const SignInResult.switchedToExisting(),
      );
      verifyInOrder([
        () => transition.prepareForAccountSwitch(),
        () => auth.signOut(),
        () => custom.signInWithCustomToken(token),
        () => functions.recordSignInEvent(),
      ]);
      expect(identityChanges, ['before']);
    });

    test('Firebase refusing the token fails the sign-in', () async {
      when(() => codes.verifyCode(any(), any()))
          .thenAnswer((_) async => _token('other'));
      when(() => custom.signInWithCustomToken(any()))
          .thenThrow(const AuthGatewayException('invalid-custom-token'));
      when(() => auth.signInAnonymously()).thenAnswer(
        (_) async => const AuthSession(uid: 'anon-2', isAnonymous: true),
      );
      expect(
        await repository.verifyCode('juan@gmail.com', '482139'),
        const SignInResult.failed(reason: 'invalid-custom-token'),
      );
      verifyNever(() => functions.recordSignInEvent());
    });

    test('a refused code reaches the caller', () async {
      when(() => codes.verifyCode(any(), any())).thenThrow(
        const EmailCodeException(EmailCodeFailure.wrong, triesLeft: 2),
      );
      await expectLater(
        repository.verifyCode('juan@gmail.com', '000000'),
        throwsA(
          isA<EmailCodeException>().having(
            (e) => e.failure,
            'failure',
            EmailCodeFailure.wrong,
          ),
        ),
      );
      verifyNever(() => custom.signInWithCustomToken(any()));
    });

    test('without the gateways both calls are unavailable', () async {
      final bare = AuthRepository(gateway: auth);
      expect(
        () => bare.requestCode('a@b.co'),
        throwsA(isA<EmailCodeException>()),
      );
      await expectLater(
        bare.verifyCode('a@b.co', '123456'),
        throwsA(isA<EmailCodeException>()),
      );
    });
  });
}
