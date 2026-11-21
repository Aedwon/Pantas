import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';

class _Client implements ChildCallableClient {
  final calls = <(String, Map<String, Object?>)>[];
  Object? reply;
  Exception? error;

  @override
  Future<Object?> call(String name, Map<String, Object?> data) async {
    calls.add((name, data));
    final failure = error;
    if (failure != null) throw failure;
    return reply;
  }
}

FirebaseFunctionsException _refusal(String code, [String? reason]) =>
    FirebaseFunctionsException(
      message: 'refused',
      code: code,
      details: reason == null ? null : {'reason': reason},
    );

void main() {
  late _Client client;
  late CallableChildSetupGateway gateway;
  setUp(() {
    client = _Client();
    gateway = CallableChildSetupGateway(client);
  });

  test('setup sends the text versions and reads the child and token', () async {
    client.reply = {'childUid': 'child-1', 'customToken': 'token-1'};
    final result = await gateway.setupChildAccount();
    expect(result.childUid, 'child-1');
    expect(result.customToken, 'token-1');
    final (name, data) = client.calls.single;
    expect(name, 'setupChildAccount');
    expect(data, {
      'tick1TextVersion': ChildSetupVersions.tick1,
      'tick2TextVersion': ChildSetupVersions.tick2,
      'termsVersion': '2026-11-20',
      'childNoticeVersion': ChildSetupVersions.childNotice,
    });
  });

  test('setup passes a nickname and a proof when it has them', () async {
    client.reply = {'childUid': 'c', 'customToken': 't'};
    await gateway.setupChildAccount(nickname: 'Kiko', guardianProofId: 'p-1');
    final data = client.calls.single.$2;
    expect(data['nickname'], 'Kiko');
    expect(data['guardianProofId'], 'p-1');
  });

  test('a token never prints', () {
    const result = ChildSetupResult(childUid: 'c', customToken: 'secret');
    expect(result.toString(), isNot(contains('secret')));
  });

  test('a reply with no token is a failure', () async {
    client.reply = {'childUid': 'child-1'};
    await expectLater(
      gateway.setupChildAccount(),
      throwsA(
        isA<ChildSetupException>()
            .having((e) => e.failure, 'failure', ChildSetupFailure.other),
      ),
    );
  });

  group('refusal reasons', () {
    for (final (reason, failure) in [
      ('email-has-account', ChildSetupFailure.emailHasAccount),
      ('child-limit', ChildSetupFailure.childLimit),
      ('stale-consent-text', ChildSetupFailure.staleConsentText),
      ('named-sign-in-required', ChildSetupFailure.namedSignInRequired),
      ('child-accounts-closed', ChildSetupFailure.childAccountsClosed),
      ('something-new', ChildSetupFailure.other),
    ]) {
      test('$reason maps to $failure', () async {
        client.error = _refusal('failed-precondition', reason);
        await expectLater(
          gateway.setupChildAccount(),
          throwsA(
            isA<ChildSetupException>()
                .having((e) => e.failure, 'failure', failure),
          ),
        );
      });
    }

    test('too many calls with no reason is rate limited', () async {
      client.error = _refusal('resource-exhausted');
      await expectLater(
        gateway.setupChildAccount(),
        throwsA(
          isA<ChildSetupException>().having(
            (e) => e.failure,
            'failure',
            ChildSetupFailure.rateLimited,
          ),
        ),
      );
    });

    test('an error with no details is other', () async {
      client.error = _refusal('internal');
      await expectLater(
        gateway.setupChildAccount(),
        throwsA(
          isA<ChildSetupException>()
              .having((e) => e.failure, 'failure', ChildSetupFailure.other),
        ),
      );
    });
  });

  test('every refusal has a plain message that is not the 2AE error', () {
    expect(
      ChildSetupFailure.emailHasAccount.message,
      'This email already has a Pantas account. Use another email.',
    );
    for (final failure in ChildSetupFailure.values) {
      expect(failure.message, isNotEmpty);
      expect(failure.message, isNot(contains(String.fromCharCode(0x2014))));
      if (failure != ChildSetupFailure.emailHasAccount) {
        expect(failure.message, isNot(ChildSetupCopy.emailHasAccount));
      }
    }
  });

  test('the nickname call names the child and the nickname', () async {
    await gateway.setChildNickname(childId: 'child-1', nickname: 'Kiko');
    final (name, data) = client.calls.single;
    expect(name, 'setChildNickname');
    expect(data, {'childId': 'child-1', 'nickname': 'Kiko'});
  });

  test('a nickname refusal keeps its reason', () async {
    client.error = _refusal('invalid-argument', 'invalid-nickname');
    await expectLater(
      gateway.setChildNickname(childId: 'c', nickname: ''),
      throwsA(isA<ChildSetupException>()),
    );
  });
}
