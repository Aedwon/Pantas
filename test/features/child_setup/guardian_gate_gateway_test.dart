import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';

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

FirebaseFunctionsException _refusal(
  String code, {
  String? reason,
  Map<String, Object?> extra = const {},
}) =>
    FirebaseFunctionsException(
      message: 'refused',
      code: code,
      details: {if (reason != null) 'reason': reason, ...extra},
    );

void main() {
  late _Client client;
  late CallableChildSetupGateway gateway;
  setUp(() {
    client = _Client();
    gateway = CallableChildSetupGateway(client);
  });

  group('requestGuardianCode', () {
    test('sends the action and child and reads the masked email', () async {
      client.reply = {
        'maskedEmail': 'm***@example.test',
        'resendAfterSeconds': 60,
        'expiresInSeconds': 600,
      };
      final sent = await gateway.requestGuardianCode(
        action: GuardianAction.withdraw,
        childId: 'child-1',
      );
      expect(sent.maskedEmail, 'm***@example.test');
      expect(sent.resendAfterSeconds, 60);
      expect(sent.expiresInSeconds, 600);
      final (name, data) = client.calls.single;
      expect(name, 'requestGuardianCode');
      expect(data, {'action': 'withdraw', 'childId': 'child-1'});
    });

    test('adding a child names no child', () async {
      client.reply = {
        'maskedEmail': 'm***@example.test',
        'resendAfterSeconds': 60,
        'expiresInSeconds': 600,
      };
      await gateway.requestGuardianCode(action: GuardianAction.addChild);
      expect(client.calls.single.$2, {'action': 'addChild'});
    });

    test('a reply without the masked email is a failure', () async {
      client.reply = {'resendAfterSeconds': 60};
      await expectLater(
        gateway.requestGuardianCode(
          action: GuardianAction.delete,
          childId: 'c',
        ),
        throwsA(
          isA<GuardianGateException>()
              .having((e) => e.failure, 'failure', GuardianGateFailure.other),
        ),
      );
    });

    test('the daily limit has its own failure', () async {
      client.error = _refusal(
        'resource-exhausted',
        reason: 'guardian-code-daily-limit',
      );
      await expectLater(
        gateway.requestGuardianCode(
          action: GuardianAction.delete,
          childId: 'c',
        ),
        throwsA(
          isA<GuardianGateException>().having(
            (e) => e.failure,
            'failure',
            GuardianGateFailure.dailyLimit,
          ),
        ),
      );
    });

    test('a limit with no reason is rate limited', () async {
      client.error = _refusal('resource-exhausted');
      await expectLater(
        gateway.requestGuardianCode(
          action: GuardianAction.delete,
          childId: 'c',
        ),
        throwsA(
          isA<GuardianGateException>().having(
            (e) => e.failure,
            'failure',
            GuardianGateFailure.rateLimited,
          ),
        ),
      );
    });

    test('a mail that could not be sent is a send failure', () async {
      client.error = _refusal('unavailable');
      await expectLater(
        gateway.requestGuardianCode(
          action: GuardianAction.delete,
          childId: 'c',
        ),
        throwsA(
          isA<GuardianGateException>().having(
            (e) => e.failure,
            'failure',
            GuardianGateFailure.sendFailed,
          ),
        ),
      );
    });
  });

  group('verifyGuardianCode', () {
    test('sends the code and returns the proof', () async {
      client.reply = {'proof': 'a' * 32, 'expiresInSeconds': 300};
      final proof = await gateway.verifyGuardianCode(
        action: GuardianAction.withdraw,
        childId: 'child-1',
        code: '123456',
      );
      expect(proof, 'a' * 32);
      final (name, data) = client.calls.single;
      expect(name, 'verifyGuardianCode');
      expect(data, {
        'action': 'withdraw',
        'childId': 'child-1',
        'code': '123456',
      });
    });

    test('a reply with no proof is a failure', () async {
      client.reply = {'expiresInSeconds': 300};
      await expectLater(
        gateway.verifyGuardianCode(
          action: GuardianAction.withdraw,
          childId: 'c',
          code: '123456',
        ),
        throwsA(
          isA<GuardianGateException>()
              .having((e) => e.failure, 'failure', GuardianGateFailure.other),
        ),
      );
    });

    test('a wrong code carries the tries left', () async {
      client.error = _refusal(
        'invalid-argument',
        reason: 'wrong',
        extra: {'triesLeft': 3},
      );
      await expectLater(
        gateway.verifyGuardianCode(
          action: GuardianAction.delete,
          childId: 'c',
          code: '000000',
        ),
        throwsA(
          isA<GuardianGateException>()
              .having((e) => e.failure, 'failure', GuardianGateFailure.wrong)
              .having((e) => e.triesLeft, 'triesLeft', 3),
        ),
      );
    });

    for (final (code, reason, failure) in [
      ('resource-exhausted', 'tooManyTries', GuardianGateFailure.tooManyTries),
      ('not-found', 'expired', GuardianGateFailure.expired),
      ('permission-denied', 'not-linked', GuardianGateFailure.notLinked),
      (
        'permission-denied',
        'guardian-proof-invalid',
        GuardianGateFailure.proofInvalid,
      ),
    ]) {
      test('$reason maps to $failure', () async {
        client.error = _refusal(code, reason: reason);
        await expectLater(
          gateway.verifyGuardianCode(
            action: GuardianAction.delete,
            childId: 'c',
            code: '000000',
          ),
          throwsA(
            isA<GuardianGateException>()
                .having((e) => e.failure, 'failure', failure),
          ),
        );
      });
    }
  });

  group('closing a child', () {
    test('withdrawChild sends the child and the proof', () async {
      client.reply = {'deletedAt': '2026-11-21T00:00:00.000Z'};
      await gateway.withdrawChild(
        childId: 'child-1',
        guardianProofId: 'p' * 32,
      );
      final (name, data) = client.calls.single;
      expect(name, 'withdrawChild');
      expect(data, {'childId': 'child-1', 'guardianProofId': 'p' * 32});
    });

    test('deleteChild sends the child and the proof', () async {
      client.reply = {'deletedAt': '2026-11-21T00:00:00.000Z'};
      await gateway.deleteChild(childId: 'child-1', guardianProofId: 'p' * 32);
      final (name, data) = client.calls.single;
      expect(name, 'deleteChild');
      expect(data, {'childId': 'child-1', 'guardianProofId': 'p' * 32});
    });

    test('a refusal is a failure the screen can show', () async {
      client.error = _refusal(
        'permission-denied',
        reason: 'guardian-proof-invalid',
      );
      await expectLater(
        gateway.deleteChild(childId: 'c', guardianProofId: 'p'),
        throwsA(
          isA<GuardianGateException>().having(
            (e) => e.failure,
            'failure',
            GuardianGateFailure.proofInvalid,
          ),
        ),
      );
    });
  });

  test('the action names match the server', () {
    expect(
      GuardianAction.values.map((a) => a.serverName),
      [
        'addChild',
        'dataCopy',
        'withdraw',
        'delete',
        'siblingOptIn',
        'switchInto',
      ],
    );
  });
}
