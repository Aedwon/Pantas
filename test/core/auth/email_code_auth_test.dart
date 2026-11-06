import 'dart:async';
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

class _Wiper implements LocalStateWiper {
  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async {}
}

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
          'requestSignInCode': {
            'challengeId': 'c-1',
            'resendAfterSeconds': 42,
          },
        },
      );
      final request = await FirebaseEmailCodeGateway(
        client: client,
      ).requestCode('juan@gmail.com');
      expect(request.resendAfterSeconds, 42);
      expect(request.challengeId, 'c-1');
      expect(client.calls.single.name, 'requestSignInCode');
      expect(client.calls.single.region, 'asia-southeast1');
      expect(client.calls.single.data, {'email': 'juan@gmail.com'});
    });

    test('a cooldown answer has no challenge', () async {
      for (final answer in [
        {'resendAfterSeconds': 17},
        {'resendAfterSeconds': 17, 'challengeId': ''},
      ]) {
        final request = await FirebaseEmailCodeGateway(
          client: RecordingFunctionsClient(
            responses: {'requestSignInCode': answer},
          ),
        ).requestCode('juan@gmail.com');
        expect(request.challengeId, isNull);
        expect(request.resendAfterSeconds, 17);
      }
    });

    test('a challenge that is not text is unavailable', () async {
      await expectLater(
        FirebaseEmailCodeGateway(
          client: RecordingFunctionsClient(
            responses: {
              'requestSignInCode': {'resendAfterSeconds': 5, 'challengeId': 7},
            },
          ),
        ).requestCode('juan@gmail.com'),
        throwsA(isA<EmailCodeException>()),
      );
    });

    test('verifies a code and returns the token', () async {
      final client = RecordingFunctionsClient(
        responses: {
          'verifySignInCode': {'token': 'abc'},
        },
      );
      final token = await FirebaseEmailCodeGateway(
        client: client,
      ).verifyCode('c-1', '482139');
      expect(token, 'abc');
      expect(client.calls.single.name, 'verifySignInCode');
      expect(client.calls.single.data, {
        'challengeId': 'c-1',
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
      when(() => codes.requestCode(any())).thenAnswer(
        (_) async => const EmailCodeRequest(
          resendAfterSeconds: 60,
          challengeId: 'c-1',
        ),
      );
      final request = await repository.requestCode(' Juan@Gmail.COM ');
      expect(request.challengeId, 'c-1');
      verify(() => codes.requestCode('juan@gmail.com')).called(1);
    });

    test('a token for the anonymous uid signs in without a switch', () async {
      final token = _token('anon');
      when(() => codes.verifyCode(any(), any())).thenAnswer((_) async => token);
      expect(
        await repository.verifyCode('c-1', '482139'),
        const SignInResult.linkedExisting(),
      );
      verify(() => codes.verifyCode('c-1', '482139')).called(1);
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
        await repository.verifyCode('c-1', '482139'),
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
        await repository.verifyCode('c-1', '482139'),
        const SignInResult.failed(reason: 'invalid-custom-token'),
      );
      verifyNever(() => functions.recordSignInEvent());
    });

    test('a refused code reaches the caller', () async {
      when(() => codes.verifyCode(any(), any())).thenThrow(
        const EmailCodeException(EmailCodeFailure.wrong, triesLeft: 2),
      );
      await expectLater(
        repository.verifyCode('c-1', '000000'),
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

    group('a result that arrives late', () {
      late Completer<String> server;

      setUp(() {
        server = Completer<String>();
        when(() => codes.verifyCode(any(), any()))
            .thenAnswer((_) => server.future);
      });

      void expectUntouched() {
        verifyNever(() => custom.signInWithCustomToken(any()));
        verifyNever(() => transition.prepareForAccountSwitch());
        verifyNever(() => auth.signOut());
        verifyNever(() => functions.recordSignInEvent());
      }

      test('is dropped when the signed-in user changed', () async {
        final result = repository.verifyCode('c-1', '482139');
        await Future<void>.delayed(Duration.zero);
        when(() => auth.currentSession).thenReturn(
          const AuthSession(uid: 'someone-else', email: 'x@y.co'),
        );
        server.complete(_token('anon'));
        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('is dropped when the user signed out meanwhile', () async {
        final result = repository.verifyCode('c-1', '482139');
        await Future<void>.delayed(Duration.zero);
        when(() => auth.currentSession).thenReturn(null);
        server.complete(_token('other'));
        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('is dropped when the flow was cancelled', () async {
        final result = repository.verifyCode('c-1', '482139');
        await Future<void>.delayed(Duration.zero);
        repository.cancelVerification();
        server.complete(_token('other'));
        expect(await result, const SignInResult.cancelled());
        expectUntouched();
      });

      test('is dropped when the repository signed out meanwhile', () async {
        when(() => transition.prepareForSignOut()).thenAnswer((_) async {});
        when(() => auth.signInAnonymously()).thenAnswer(
          (_) async => const AuthSession(uid: 'anon-2', isAnonymous: true),
        );
        final wiper = _Wiper();
        final repo = AuthRepository(
          gateway: auth,
          emailCodeGateway: codes,
          customTokenGateway: custom,
          accountTransitionGateway: transition,
          functionsGateway: functions,
          localStateWiper: wiper,
        );
        final result = repo.verifyCode('c-1', '482139');
        await Future<void>.delayed(Duration.zero);
        await repo.signOut();
        clearInteractions(auth);
        clearInteractions(transition);
        server.complete(_token('other'));
        expect(await result, const SignInResult.cancelled());
        verifyNever(() => custom.signInWithCustomToken(any()));
        verifyNever(() => transition.prepareForAccountSwitch());
      });

      test('still signs in when nothing changed', () async {
        final result = repository.verifyCode('c-1', '482139');
        await Future<void>.delayed(Duration.zero);
        server.complete(_token('anon'));
        expect(await result, const SignInResult.linkedExisting());
      });
    });

    test('only one check runs at a time', () async {
      final first = Completer<String>();
      final second = Completer<String>();
      final answers = [first, second];
      when(() => codes.verifyCode(any(), any()))
          .thenAnswer((_) => answers.removeAt(0).future);

      final one = repository.verifyCode('c-1', '111111');
      final two = repository.verifyCode('c-2', '222222');
      await Future<void>.delayed(Duration.zero);
      verify(() => codes.verifyCode('c-1', '111111')).called(1);
      verifyNever(() => codes.verifyCode('c-2', '222222'));

      first.complete(_token('anon'));
      expect(await one, const SignInResult.linkedExisting());
      await Future<void>.delayed(Duration.zero);
      verify(() => codes.verifyCode('c-2', '222222')).called(1);
      second.complete(_token('anon'));
      expect(await two, const SignInResult.linkedExisting());
    });

    test('a check cancelled while it waits its turn is skipped', () async {
      final first = Completer<String>();
      when(() => codes.verifyCode(any(), any()))
          .thenAnswer((_) => first.future);
      final one = repository.verifyCode('c-1', '111111');
      final two = repository.verifyCode('c-2', '222222');
      await Future<void>.delayed(Duration.zero);
      repository.cancelVerification();
      first.complete(_token('anon'));
      expect(await one, const SignInResult.cancelled());
      expect(await two, const SignInResult.cancelled());
      verifyNever(() => codes.verifyCode('c-2', '222222'));
      verifyNever(() => custom.signInWithCustomToken(any()));
    });

    test('a refused check does not block the next one', () async {
      when(() => codes.verifyCode('c-1', any())).thenThrow(
        const EmailCodeException(EmailCodeFailure.wrong),
      );
      await expectLater(
        repository.verifyCode('c-1', '000000'),
        throwsA(isA<EmailCodeException>()),
      );
      when(() => codes.verifyCode('c-1', '482139'))
          .thenAnswer((_) async => _token('anon'));
      expect(
        await repository.verifyCode('c-1', '482139'),
        const SignInResult.linkedExisting(),
      );
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
