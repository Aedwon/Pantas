import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

Map<String, Object?> _view({bool paused = false, List<Object?>? answers}) => {
      'mockId': 'abcdefghij1',
      'examId': 'exam_cse_pro',
      'startedAt': 1790000000000,
      'strict': false,
      'limitMs': 9000000,
      'remainingMs': 8000000,
      'paused': paused,
      'paper': {
        'expectedQuestionCount': 2,
        'sections': [
          {
            'sectionId': 'gi',
            'name': 'General Information',
            'questions': [
              {'id': 'q1', 'setId': 's'},
              {'id': 'q2', 'setId': 's'},
            ],
          },
        ],
      },
      'answers': answers ?? <Object?>[],
    };

class _Recorder {
  final calls = <(String, Map<String, Object?>)>[];
  Object? reply;
  Exception? error;

  Future<Object?> call(String name, Map<String, Object?> data) async {
    calls.add((name, Map.of(data)));
    if (error != null) throw error!;
    return reply;
  }
}

ServerMockAnswer _answer(String id, {String? chosen = 'a'}) => ServerMockAnswer(
      questionId: id,
      chosen: chosen,
      correct: chosen == 'a',
      answeredAt: 1790000100000,
    );

void main() {
  late _Recorder server;
  late ServerMockApi api;

  setUp(() {
    server = _Recorder();
    api = ServerMockApi(server.call);
  });

  test('startMock sends the exam and strict flag and decodes the paper',
      () async {
    server.reply = {..._view(), 'resumed': true};

    final started = await api.start(examId: 'exam_cse_pro', strict: true);

    expect(server.calls.single.$1, 'startMock');
    expect(server.calls.single.$2, {'examId': 'exam_cse_pro', 'strict': true});
    expect(started.resumed, isTrue);
    expect(started.paper.mockId, 'abcdefghij1');
    expect(started.paper.examId, 'exam_cse_pro');
  });

  test('a start response without the resumed flag is refused', () async {
    server.reply = _view();
    await expectLater(
      api.start(examId: 'exam_cse_pro', strict: false),
      throwsA(isA<ServerMockFormatException>()),
    );
  });

  test('getMockPaper returns the open mock', () async {
    server.reply = {'open': true, ..._view()};
    final read = await api.read();
    expect(server.calls.single.$1, 'getMockPaper');
    expect(server.calls.single.$2, isEmpty);
    expect((read as ServerMockOpen).paper.mockId, 'abcdefghij1');
  });

  test('getMockPaper says when nothing is open', () async {
    server.reply = {'open': false};
    final read = await api.read();
    expect(read, isA<ServerMockNone>());
  });

  test('getMockPaper reports a strict mock that ended on time', () async {
    server.reply = {
      'open': false,
      'ended': {
        'mockId': 'abcdefghij1',
        'endedBy': 'time-out',
        'submittedAt': 1790009000000,
        'score': {'correct': 60, 'answered': 100, 'total': 155},
      },
    };
    final read = await api.read();
    final ended = (read as ServerMockEnded).ended;
    expect(ended.endedBy, ServerMockEndedBy.timeOut);
    expect(ended.mockId, 'abcdefghij1');
  });

  test('an unknown way of ending is refused', () async {
    server.reply = {
      'open': false,
      'ended': {
        'mockId': 'abcdefghij1',
        'endedBy': 'robot',
        'submittedAt': 1,
        'score': {'correct': 1, 'answered': 1, 'total': 1},
      },
    };
    await expectLater(
      api.read(),
      throwsA(isA<ServerMockFormatException>()),
    );
  });

  group('controlMock', () {
    test('pause, resume and discard send only the action', () async {
      server.reply = _view(paused: true);
      for (final action in [
        ServerMockAction.pause,
        ServerMockAction.resume,
        ServerMockAction.discard,
      ]) {
        await api.control(mockId: 'abcdefghij1', action: action);
      }
      expect(server.calls.map((c) => c.$1), everyElement('controlMock'));
      expect(server.calls.map((c) => c.$2['action']), [
        'pause',
        'resume',
        'discard',
      ]);
      expect(server.calls.every((c) => !c.$2.containsKey('answers')), isTrue);
    });

    test('save sends the exact answers it was given', () async {
      server.reply = _view();
      final answers = [_answer('q1'), _answer('q2', chosen: null)];
      await api.control(
        mockId: 'abcdefghij1',
        action: ServerMockAction.save,
        answers: answers,
      );
      expect(server.calls.single.$2, {
        'mockId': 'abcdefghij1',
        'action': 'save',
        'answers': [for (final a in answers) a.toJson()],
      });
    });

    test('a save the server would reject is never sent', () async {
      server.reply = _view();
      for (final answers in <List<ServerMockAnswer>?>[
        null,
        const [],
        [for (var i = 0; i < 301; i++) _answer('q$i')],
        [_answer('x' * 129)],
        [_answer('q1', chosen: 'c' * 65)],
      ]) {
        await expectLater(
          api.control(
            mockId: 'abcdefghij1',
            action: ServerMockAction.save,
            answers: answers,
          ),
          throwsArgumentError,
        );
      }
      expect(server.calls, isEmpty);
    });

    test('answers are refused on actions that do not take them', () async {
      await expectLater(
        api.control(
          mockId: 'abcdefghij1',
          action: ServerMockAction.pause,
          answers: [_answer('q1')],
        ),
        throwsArgumentError,
      );
      expect(server.calls, isEmpty);
    });

    test('a bad mock id is never sent', () async {
      await expectLater(
        api.control(mockId: 'x', action: ServerMockAction.pause),
        throwsArgumentError,
      );
      expect(server.calls, isEmpty);
    });
  });

  group('submitMock', () {
    test('a student submission sends answers and the time used', () async {
      server.reply = {'mockId': 'abcdefghij1', 'status': 'submitted'};
      final result = await api.submit(
        mockId: 'abcdefghij1',
        answers: [_answer('q1'), _answer('q2', chosen: null)],
        durationMs: 1234,
        reason: ServerMockEndReason.student,
      );
      expect(result.status, 'submitted');
      expect(server.calls.single.$1, 'submitMock');
      expect(server.calls.single.$2['reason'], 'student');
      expect(server.calls.single.$2['durationMs'], 1234);
      expect(server.calls.single.$2['answers'], hasLength(2));
    });

    test('a strict exit may carry no answers', () async {
      server.reply = {'mockId': 'abcdefghij1', 'status': 'submitted'};
      await api.submit(
        mockId: 'abcdefghij1',
        answers: const [],
        durationMs: 0,
        reason: ServerMockEndReason.strictExit,
      );
      expect(server.calls.single.$2['reason'], 'strict-exit');
      expect(server.calls.single.$2['answers'], isEmpty);
    });

    test('a student submission without answers is never sent', () async {
      await expectLater(
        api.submit(
          mockId: 'abcdefghij1',
          answers: const [],
          durationMs: 0,
          reason: ServerMockEndReason.student,
        ),
        throwsArgumentError,
      );
      expect(server.calls, isEmpty);
    });

    test('an impossible time is never sent', () async {
      for (final ms in [-1, 86400001]) {
        await expectLater(
          api.submit(
            mockId: 'abcdefghij1',
            answers: [_answer('q1')],
            durationMs: ms,
            reason: ServerMockEndReason.student,
          ),
          throwsArgumentError,
        );
      }
      expect(server.calls, isEmpty);
    });

    test('a reply that is not a submission is refused', () async {
      server.reply = {'mockId': 'abcdefghij1', 'status': 'started'};
      await expectLater(
        api.submit(
          mockId: 'abcdefghij1',
          answers: [_answer('q1')],
          durationMs: 1,
          reason: ServerMockEndReason.student,
        ),
        throwsA(isA<ServerMockFormatException>()),
      );
    });
  });

  test('a refusal from the server keeps its code', () async {
    server.error = const ServerMockException(
      code: 'failed-precondition',
      message: 'Free accounts can take one mock every 30 days.',
    );
    await expectLater(
      api.start(examId: 'exam_cse_pro', strict: false),
      throwsA(
        isA<ServerMockException>()
            .having((e) => e.code, 'code', 'failed-precondition'),
      ),
    );
  });

  test('a response that is not an object is refused', () async {
    server.reply = 'nope';
    await expectLater(
      api.read(),
      throwsA(isA<ServerMockFormatException>()),
    );
  });
}
