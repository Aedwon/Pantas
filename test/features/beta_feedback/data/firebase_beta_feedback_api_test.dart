import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

class _Call {
  _Call(this.name, this.data);
  final String name;
  final Map<String, Object?> data;
}

class _Upload {
  _Upload(this.path, this.bytes, this.contentType);
  final String path;
  final Uint8List bytes;
  final String contentType;
}

FirebaseFunctionsException _error(String code) =>
    // The constructor is protected for the plugin; a test needs one.
    // ignore: invalid_use_of_protected_member
    FirebaseFunctionsException(message: code, code: code);

PickedImage _image(int length, [String type = 'image/png']) => PickedImage(
      bytes: Uint8List(length),
      contentType: type,
    );

void main() {
  late List<_Call> calls;
  late List<_Upload> uploads;
  late Object? Function(String name) reply;
  late Error? uploadError;
  late StreamController<List<BetaSentRow>> rows;
  late String? uid;
  late String? examId;

  FirebaseBetaFeedbackApi build() => FirebaseBetaFeedbackApi(
        uid: () => uid,
        examId: () => examId,
        userAgent: () => 'Agent/1.0',
        appVersion: () => 'build 7',
        callable: (name, data) async {
          calls.add(_Call(name, data));
          final value = reply(name);
          if (value is Exception) throw value;
          return value;
        },
        upload: (path, bytes, contentType) async {
          if (uploadError != null) throw uploadError!;
          uploads.add(_Upload(path, bytes, contentType));
        },
        readSent: (id) => rows.stream,
        downloadUrl: (path) async => 'https://files.test/$path',
      );

  setUp(() {
    calls = [];
    uploads = [];
    uploadError = null;
    reply = (_) => <String, Object?>{};
    rows = StreamController<List<BetaSentRow>>.broadcast();
    uid = 'user1';
    examId = null;
  });

  tearDown(() => rows.close());

  group('send', () {
    const id = 'AbCdEfGhIjKlMnOpQrSt';

    test('uploads each image then calls the callable with the paths', () async {
      reply = (_) => {'feedbackId': id, 'createdAt': 1000};
      final sent = await build().send(
        feedbackId: id,
        text: '  It crashes  ',
        images: [_image(3), _image(4, 'image/jpeg')],
      );
      expect(uploads.map((u) => u.path), [
        'betaFeedback/user1/$id/0',
        'betaFeedback/user1/$id/1',
      ]);
      expect(uploads.map((u) => u.contentType), ['image/png', 'image/jpeg']);
      expect(uploads.map((u) => u.bytes.length), [3, 4]);
      expect(calls.single.name, 'sendBetaFeedback');
      expect(calls.single.data, {
        'feedbackId': id,
        'text': 'It crashes',
        'attachments': [
          {'path': 'betaFeedback/user1/$id/0', 'contentType': 'image/png'},
          {'path': 'betaFeedback/user1/$id/1', 'contentType': 'image/jpeg'},
        ],
        'userAgent': 'Agent/1.0',
        'appVersion': 'build 7',
      });
      expect(sent.id, id);
      expect(sent.text, 'It crashes');
      expect(sent.createdAt, DateTime.fromMillisecondsSinceEpoch(1000));
      expect(sent.attachments.map((a) => a.path), [
        'betaFeedback/user1/$id/0',
        'betaFeedback/user1/$id/1',
      ]);
    });

    test('sends the exam when there is one and cuts long context', () async {
      reply = (_) => {'feedbackId': id, 'createdAt': 5};
      examId = 'exam_student';
      final api = FirebaseBetaFeedbackApi(
        uid: () => uid,
        examId: () => examId,
        userAgent: () => 'u' * 400,
        appVersion: () => 'v' * 90,
        callable: (name, data) async {
          calls.add(_Call(name, data));
          return reply(name);
        },
        upload: (path, bytes, contentType) async {},
        readSent: (id) => rows.stream,
        downloadUrl: (path) async => path,
      );
      await api.send(feedbackId: id, text: 'Hi', images: const []);
      expect(calls.single.data['examId'], 'exam_student');
      expect((calls.single.data['userAgent']! as String).length, 300);
      expect((calls.single.data['appVersion']! as String).length, 40);
      expect(calls.single.data['attachments'], isEmpty);
    });

    test('a failed upload stops before the callable and fails as other',
        () async {
      uploadError = StateError('offline');
      await expectLater(
        build().send(feedbackId: id, text: 'Hi', images: [_image(2)]),
        throwsA(
          isA<BetaFeedbackException>()
              .having((e) => e.failure, 'failure', BetaFeedbackFailure.other),
        ),
      );
      expect(calls, isEmpty);
    });

    test('a retry with the same id uploads to the same paths', () async {
      reply = (_) => {'feedbackId': id, 'createdAt': 9};
      final api = build();
      await api.send(feedbackId: id, text: 'Hi', images: [_image(2)]);
      await api.send(feedbackId: id, text: 'Hi', images: [_image(2)]);
      expect(uploads.map((u) => u.path).toSet(), {'betaFeedback/user1/$id/0'});
    });

    test('signed out fails as other before any work', () async {
      uid = null;
      await expectLater(
        build().send(feedbackId: id, text: 'Hi', images: [_image(2)]),
        throwsA(isA<BetaFeedbackException>()),
      );
      expect(uploads, isEmpty);
      expect(calls, isEmpty);
    });

    test('a malformed reply fails as other', () async {
      reply = (_) => 'nope';
      await expectLater(
        build().send(feedbackId: id, text: 'Hi', images: const []),
        throwsA(
          isA<BetaFeedbackException>()
              .having((e) => e.failure, 'failure', BetaFeedbackFailure.other),
        ),
      );
    });
  });

  group('error mapping', () {
    final cases = {
      'failed-precondition': BetaFeedbackFailure.notAllowed,
      'already-exists': BetaFeedbackFailure.alreadyDone,
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
          uid: () => uid,
          examId: () => null,
          userAgent: () => '',
          appVersion: () => '',
          callable: (_, __) async => throw const FormatException('bad'),
          upload: (_, __, ___) async {},
          readSent: (_) => rows.stream,
          downloadUrl: (_) async => '',
        ).recordDay(BetaDayKind.plan),
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

  group('recordDay', () {
    test('sends the kind', () async {
      await build().recordDay(BetaDayKind.plan);
      await build().recordDay(BetaDayKind.restDay);
      expect(calls.map((c) => c.name), ['recordBetaDay', 'recordBetaDay']);
      expect(calls.map((c) => c.data['kind']), ['plan', 'restDay']);
    });
  });

  group('submitSurvey', () {
    test('maps every answer to the server values', () async {
      await build().submitSurvey(
        const SurveyAnswers(
          usage: SurveyUsage.fewDays,
          ease: 4,
          usefulness: 5,
          keepUsing: SurveyContinue.maybe,
          recommend: 9,
          improve: 'Speed',
          other: ' Thanks ',
        ),
      );
      expect(calls.single.name, 'submitBetaSurvey');
      expect(calls.single.data, {
        'answers': {
          'usage': 'few_days',
          'ease': 4,
          'usefulness': 5,
          'continue': 'maybe',
          'recommend': 9,
          'improve': 'Speed',
          'other': 'Thanks',
        },
      });
    });

    test('leaves out an empty optional answer', () async {
      await build().submitSurvey(
        const SurveyAnswers(
          usage: SurveyUsage.everyDay,
          ease: 1,
          usefulness: 1,
          keepUsing: SurveyContinue.yes,
          recommend: 0,
          improve: 'More',
          other: '  ',
        ),
      );
      final answers = calls.single.data['answers']! as Map<String, Object?>;
      expect(answers.containsKey('other'), isFalse);
      expect(answers['usage'], 'every_day');
    });

    test('maps the other two usage and continue values', () async {
      for (final (usage, expected) in [
        (SurveyUsage.mostDays, 'most_days'),
        (SurveyUsage.once, 'once'),
      ]) {
        calls.clear();
        await build().submitSurvey(
          SurveyAnswers(
            usage: usage,
            ease: 3,
            usefulness: 3,
            keepUsing: SurveyContinue.no,
            recommend: 5,
            improve: 'x',
          ),
        );
        final answers = calls.single.data['answers']! as Map<String, Object?>;
        expect(answers['usage'], expected);
        expect(answers['continue'], 'no');
      }
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

  group('sent', () {
    test('maps rows newest first and skips rows without a date', () async {
      final events = <List<SentFeedback>>[];
      final sub = build().sent().listen(events.add);
      rows.add([
        const BetaSentRow('b', {
          'text': 'Second',
          'createdAt': 2000,
          'attachments': [
            {'path': 'betaFeedback/user1/b/0', 'contentType': 'image/png'},
          ],
        }),
        const BetaSentRow('a', {'text': 'First', 'createdAt': 1000}),
        const BetaSentRow('broken', {'text': 'No date'}),
      ]);
      await pumpEventQueue();
      await sub.cancel();
      expect(events, hasLength(1));
      final list = events.single;
      expect(list.map((s) => s.id), ['b', 'a']);
      expect(list.first.text, 'Second');
      expect(list.first.createdAt, DateTime.fromMillisecondsSinceEpoch(2000));
      expect(list.first.attachments.single.path, 'betaFeedback/user1/b/0');
      expect(list.first.attachments.single.contentType, 'image/png');
      expect(list.last.attachments, isEmpty);
    });

    test('emits again when a new row arrives', () async {
      final events = <List<SentFeedback>>[];
      final sub = build().sent().listen(events.add);
      rows
        ..add([
          const BetaSentRow('a', {'text': 'One', 'createdAt': 1}),
        ])
        ..add([
          const BetaSentRow('b', {'text': 'Two', 'createdAt': 2}),
          const BetaSentRow('a', {'text': 'One', 'createdAt': 1}),
        ]);
      await pumpEventQueue();
      await sub.cancel();
      expect(events.map((e) => e.length), [1, 2]);
    });

    test('signed out gives an empty list', () async {
      uid = null;
      expect(await build().sent().first, isEmpty);
    });
  });

  test('imageUrl asks for the download URL of the path', () async {
    expect(
      await build().imageUrl('betaFeedback/user1/a/0'),
      'https://files.test/betaFeedback/user1/a/0',
    );
  });

  group('newBetaFeedbackId', () {
    test('is 20 characters of letters and digits', () {
      final ids = {for (var i = 0; i < 200; i++) newBetaFeedbackId()};
      expect(ids, hasLength(200));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
      }
    });
  });
}
