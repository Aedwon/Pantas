import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

class _Call {
  _Call(this.name, this.data);
  final String name;
  final Map<String, Object?> data;
}

FirebaseFunctionsException _error(String code) =>
    // The constructor is protected for the plugin; a test needs one.
    // ignore: invalid_use_of_protected_member
    FirebaseFunctionsException(message: code, code: code);

void main() {
  late List<_Call> calls;
  late Object? Function(String name) reply;

  FirebaseBetaFeedbackApi build() => FirebaseBetaFeedbackApi(
        callable: (name, data) async {
          calls.add(_Call(name, data));
          final value = reply(name);
          if (value is Exception) throw value;
          return value;
        },
      );

  setUp(() {
    calls = [];
    reply = (_) => <String, Object?>{};
  });

  group('error mapping', () {
    final cases = {
      'failed-precondition': BetaFeedbackFailure.notAllowed,
      'permission-denied': BetaFeedbackFailure.other,
      'unavailable': BetaFeedbackFailure.other,
      'resource-exhausted': BetaFeedbackFailure.other,
    };
    for (final entry in cases.entries) {
      test('${entry.key} becomes ${entry.value.name}', () async {
        reply = (_) => _error(entry.key);
        await expectLater(
          build().activate(),
          throwsA(
            isA<BetaFeedbackException>()
                .having((e) => e.failure, 'failure', entry.value),
          ),
        );
      });
    }

    test('a non-Firebase error becomes other', () async {
      await expectLater(
        FirebaseBetaFeedbackApi(
          callable: (_, __) async => throw const FormatException('bad'),
        ).reward(),
        throwsA(
          isA<BetaFeedbackException>()
              .having((e) => e.failure, 'failure', BetaFeedbackFailure.other),
        ),
      );
    });
  });

  group('reward', () {
    test('reads the status and turns milliseconds into dates', () async {
      reply = (_) => {
            'days': ['2026-11-09', '2026-11-10'],
            'betaDays': [
              for (var d = 9; d <= 15; d++)
                '2026-11-${d.toString().padLeft(2, '0')}',
            ],
            'surveyOpensAt': 1000,
            'surveyClosesAt': 2000,
            'surveySubmitted': true,
            'eligible': true,
            'activatedAt': null,
            'rewardStartsAt': null,
            'rewardEndsAt': null,
            'activationDeadline': 3000,
          };
      final reward = await build().reward();
      expect(calls.single.name, 'getBetaReward');
      expect(calls.single.data, isEmpty);
      expect(reward.days, ['2026-11-09', '2026-11-10']);
      expect(reward.betaDays, hasLength(7));
      expect(reward.surveyOpensAt, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(reward.surveyClosesAt, DateTime.fromMillisecondsSinceEpoch(2000));
      expect(
        reward.activationDeadline,
        DateTime.fromMillisecondsSinceEpoch(3000),
      );
      expect(reward.surveySubmitted, isTrue);
      expect(reward.eligible, isTrue);
      expect(reward.activated, isFalse);
      expect(reward.rewardEndsAt, isNull);
    });

    test('reads an activated reward', () async {
      reply = (_) => {
            'days': <String>[],
            'betaDays': <String>[],
            'surveyOpensAt': 1,
            'surveyClosesAt': 2,
            'surveySubmitted': true,
            'eligible': false,
            'activatedAt': 10,
            'rewardStartsAt': 20,
            'rewardEndsAt': 30,
            'activationDeadline': 40,
          };
      final reward = await build().reward();
      expect(reward.activated, isTrue);
      expect(reward.activatedAt, DateTime.fromMillisecondsSinceEpoch(10));
      expect(reward.rewardStartsAt, DateTime.fromMillisecondsSinceEpoch(20));
      expect(reward.rewardEndsAt, DateTime.fromMillisecondsSinceEpoch(30));
    });

    test('a malformed reply fails as other', () async {
      reply = (_) => {'days': 'x'};
      await expectLater(
        build().reward(),
        throwsA(isA<BetaFeedbackException>()),
      );
    });
  });

  group('activate', () {
    test('turns the reply into dates', () async {
      reply = (_) => {'startsAt': 100, 'endsAt': 200, 'exams': 4};
      final result = await build().activate();
      expect(calls.single.name, 'activateBetaReward');
      expect(result.startsAt, DateTime.fromMillisecondsSinceEpoch(100));
      expect(result.endsAt, DateTime.fromMillisecondsSinceEpoch(200));
    });
  });
}
