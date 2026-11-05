import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

Map<String, Object?> _view({
  Object? mockId = 'abcdefghij1',
  Object? examId = 'exam_cse_pro',
  Object? startedAt = 1790000000000,
  Object? strict = false,
  Object? limitMs = 9000000,
  Object? remainingMs = 8000000,
  Object? paused = false,
  Object? paper,
  Object? answers = const <Object?>[],
}) =>
    {
      'mockId': mockId,
      'examId': examId,
      'startedAt': startedAt,
      'strict': strict,
      'limitMs': limitMs,
      'remainingMs': remainingMs,
      'paused': paused,
      'paper': paper ??
          {
            'expectedQuestionCount': 3,
            'sections': [
              {
                'sectionId': 'gi',
                'name': 'General Information',
                'questions': [
                  {'id': 'q1', 'setId': 's1'},
                  {'id': 'q2', 'setId': 's1'},
                ],
              },
              {
                'sectionId': 'va',
                'name': 'Verbal Ability',
                'questions': [
                  {'id': 'q3', 'setId': ''},
                ],
              },
            ],
          },
      'answers': answers,
    };

void main() {
  test('a valid view decodes with the server identity untouched', () {
    final paper = ServerMockPaper.decode(
      _view(
        strict: true,
        answers: [
          {
            'questionId': 'q2',
            'chosen': 'choice_b',
            'correct': true,
            'answeredAt': 1790000100000,
          },
          {
            'questionId': 'q3',
            'chosen': null,
            'correct': false,
            'answeredAt': 1790000200000,
          },
        ],
      ),
    );

    expect(paper.mockId, 'abcdefghij1');
    expect(paper.examId, 'exam_cse_pro');
    expect(paper.strict, isTrue);
    expect(paper.limit, const Duration(milliseconds: 9000000));
    expect(paper.remaining, const Duration(milliseconds: 8000000));
    expect(paper.questionIds, ['q1', 'q2', 'q3']);
    expect(paper.sections.map((s) => s.name), [
      'General Information',
      'Verbal Ability',
    ]);
    expect(paper.sectionNameOf('q3'), 'Verbal Ability');
    expect(paper.answers['q2']!.chosen, 'choice_b');
    expect(paper.answers['q3']!.chosen, isNull);
  });

  group('malformed views are refused, never guessed at', () {
    final cases = <String, Map<String, Object?>>{
      'missing mock id': _view(mockId: null),
      'bad mock id': _view(mockId: 'x'),
      'empty exam': _view(examId: ''),
      'text start time': _view(startedAt: '1790000000000'),
      'fractional limit': _view(limitMs: 1.5),
      'zero limit': _view(limitMs: 0),
      'negative remaining': _view(remainingMs: -1),
      'infinite remaining': _view(remainingMs: double.infinity),
      'remaining beyond limit': _view(remainingMs: 9000001),
      'strict as text': _view(strict: 'yes'),
      'paused as number': _view(paused: 1),
      'no sections': _view(
        paper: {'expectedQuestionCount': 0, 'sections': <Object?>[]},
      ),
      'empty section': _view(
        paper: {
          'expectedQuestionCount': 1,
          'sections': [
            {'sectionId': 'a', 'name': 'A', 'questions': <Object?>[]},
          ],
        },
      ),
      'repeated question': _view(
        paper: {
          'expectedQuestionCount': 2,
          'sections': [
            {
              'sectionId': 'a',
              'name': 'A',
              'questions': [
                {'id': 'q1', 'setId': ''},
                {'id': 'q1', 'setId': ''},
              ],
            },
          ],
        },
      ),
      'question id not text': _view(
        paper: {
          'expectedQuestionCount': 1,
          'sections': [
            {
              'sectionId': 'a',
              'name': 'A',
              'questions': [
                {'id': 7, 'setId': ''},
              ],
            },
          ],
        },
      ),
      'more questions than a save can carry': _view(
        paper: {
          'expectedQuestionCount': 301,
          'sections': [
            {
              'sectionId': 'a',
              'name': 'A',
              'questions': [
                for (var i = 0; i < 301; i++) {'id': 'q$i', 'setId': ''},
              ],
            },
          ],
        },
      ),
      'answer for a question not on the paper': _view(
        answers: [
          {
            'questionId': 'other',
            'chosen': 'a',
            'correct': true,
            'answeredAt': 1790000100000,
          },
        ],
      ),
      'two answers for one question': _view(
        answers: [
          for (var i = 0; i < 2; i++)
            {
              'questionId': 'q1',
              'chosen': 'a',
              'correct': true,
              'answeredAt': 1790000100000 + i,
            },
        ],
      ),
      'answer correctness not a flag': _view(
        answers: [
          {
            'questionId': 'q1',
            'chosen': 'a',
            'correct': 'true',
            'answeredAt': 1790000100000,
          },
        ],
      ),
      'answer time not finite': _view(
        answers: [
          {
            'questionId': 'q1',
            'chosen': 'a',
            'correct': true,
            'answeredAt': double.nan,
          },
        ],
      ),
    };
    for (final entry in cases.entries) {
      test(entry.key, () {
        expect(
          () => ServerMockPaper.decode(entry.value),
          throwsA(isA<ServerMockFormatException>()),
        );
      });
    }

    test('not an object', () {
      expect(
        () => ServerMockPaper.decode('nope'),
        throwsA(isA<ServerMockFormatException>()),
      );
    });
  });

  test('a response that ran out of time is a valid view', () {
    final paper = ServerMockPaper.decode(_view(remainingMs: 0));
    expect(paper.remaining, Duration.zero);
  });

  test('the pinned order is the order of the sections', () {
    final paper = ServerMockPaper.decode(_view());
    expect(paper.questionIds, ['q1', 'q2', 'q3']);
    expect(paper.sections.first.questions.first.setId, 's1');
  });

  group('examName', () {
    test('a custom paper carries its exam name', () {
      final paper = ServerMockPaper.decode({
        ..._view(examId: 'exam_custom_6f1d0a52'),
        'examName': 'PUP CET',
      });
      expect(paper.examName, 'PUP CET');
    });

    test('a listed paper has none', () {
      expect(ServerMockPaper.decode(_view()).examName, isNull);
    });

    test('a null or empty name is no name', () {
      expect(
        ServerMockPaper.decode({..._view(), 'examName': null}).examName,
        isNull,
      );
      expect(
        ServerMockPaper.decode({..._view(), 'examName': ''}).examName,
        isNull,
      );
    });

    test('a name that is not text is refused', () {
      expect(
        () => ServerMockPaper.decode({..._view(), 'examName': 5}),
        throwsA(isA<ServerMockFormatException>()),
      );
    });
  });

  group('by-part clocks', () {
    Map<String, Object?> parts({
      Object? index = 1,
      Object? limitsMs = const [600000, 600000, 600000],
      Object? remainingMs = 450000,
      Object? waiting = false,
      Object? endedEarly = false,
      Object? startsInMs,
    }) =>
        {
          'index': index,
          'limitsMs': limitsMs,
          'remainingMs': remainingMs,
          'waiting': waiting,
          'endedEarly': endedEarly,
          'startsInMs': startsInMs,
        };

    Map<String, Object?> byPart({
      Object? block,
      bool strict = false,
      Object? limitMs = 1800000,
      Object? remainingMs = 1050000,
    }) =>
        {
          ..._view(
            strict: strict,
            limitMs: limitMs,
            remainingMs: remainingMs,
            paper: {
              'expectedQuestionCount': 6,
              'sections': [
                for (final (i, name)
                    in ['Mathematics', 'Reasoning', 'Science'].indexed)
                  {
                    'sectionId': 's$i',
                    'name': name,
                    'questions': [
                      {'id': 'p${i}a', 'setId': ''},
                      {'id': 'p${i}b', 'setId': ''},
                    ],
                  },
              ],
            },
          ),
          'parts': block ?? parts(),
        };

    test('a running part decodes with its limits and time left', () {
      final decoded = ServerMockPaper.decode(byPart());
      final block = decoded.parts!;
      expect(block.index, 1);
      expect(block.limits, const [
        Duration(minutes: 10),
        Duration(minutes: 10),
        Duration(minutes: 10),
      ]);
      expect(block.remaining, const Duration(milliseconds: 450000));
      expect(block.waiting, isFalse);
      expect(block.endedEarly, isFalse);
      expect(block.startsIn, isNull);
      expect(block.count, 3);
    });

    test('a waiting part that the student closed decodes', () {
      final block = ServerMockPaper.decode(
        byPart(
          block: parts(
            index: 2,
            remainingMs: 600000,
            waiting: true,
            endedEarly: true,
          ),
        ),
      ).parts!;
      expect(block.waiting, isTrue);
      expect(block.endedEarly, isTrue);
      expect(block.startsIn, isNull);
    });

    test('a strict break carries the time until the part starts', () {
      final block = ServerMockPaper.decode(
        byPart(
          strict: true,
          block: parts(
            index: 2,
            remainingMs: 600000,
            waiting: true,
            startsInMs: 42000,
          ),
        ),
      ).parts!;
      expect(block.startsIn, const Duration(seconds: 42));
    });

    test('a whole double is a whole number, as on the web', () {
      final block = ServerMockPaper.decode(
        byPart(
          block: parts(
            index: 1.0,
            limitsMs: const [600000.0, 600000.0, 600000.0],
            remainingMs: 450000.0,
          ),
        ),
      ).parts!;
      expect(block.index, 1);
    });

    test('a paper without the block runs one block, as it always did', () {
      expect(ServerMockPaper.decode(_view()).parts, isNull);
      expect(ServerMockPaper.decode({..._view(), 'parts': null}).parts, isNull);
    });

    test('the block is held unchanged: nothing in it can be edited', () {
      final block = ServerMockPaper.decode(byPart()).parts!;
      expect(() => block.limits.add(Duration.zero), throwsUnsupportedError);
    });

    group('a bad block is refused', () {
      final cases = <String, Map<String, Object?>>{
        'not an object': byPart(block: 'yes'),
        'limits not a list': byPart(block: parts(limitsMs: 600000)),
        'fewer limits than parts':
            byPart(block: parts(limitsMs: const [900000, 900000])),
        'more limits than parts': byPart(
          block: parts(limitsMs: const [450000, 450000, 450000, 450000]),
        ),
        'a zero limit': byPart(
          block: parts(limitsMs: const [1200000, 600000, 0]),
        ),
        'a fractional limit': byPart(
          block: parts(limitsMs: const [600000.5, 600000, 599999.5]),
        ),
        'limits that do not add up to the paper': byPart(
          block: parts(limitsMs: const [600000, 600000, 700000]),
        ),
        'index not a number': byPart(block: parts(index: '1')),
        'index below zero': byPart(block: parts(index: -1)),
        'index past the last part': byPart(block: parts(index: 3)),
        'remaining below zero': byPart(block: parts(remainingMs: -1)),
        'remaining past the part limit':
            byPart(block: parts(remainingMs: 600001)),
        'waiting as text': byPart(block: parts(waiting: 'no')),
        'ended early as a number': byPart(block: parts(endedEarly: 0)),
        'waiting before the first part': byPart(
          block: parts(index: 0, remainingMs: 600000, waiting: true),
        ),
        'a countdown on a running part':
            byPart(strict: true, block: parts(startsInMs: 5000)),
        'a countdown that is negative': byPart(
          strict: true,
          block: parts(
            index: 2,
            remainingMs: 600000,
            waiting: true,
            startsInMs: -1,
          ),
        ),
        'a countdown when not strict': byPart(
          block: parts(
            index: 2,
            remainingMs: 600000,
            waiting: true,
            startsInMs: 5000,
          ),
        ),
        'a strict break with no countdown': byPart(
          strict: true,
          block: parts(index: 2, remainingMs: 600000, waiting: true),
        ),
        'only one part': {
          ..._view(
            limitMs: 600000,
            remainingMs: 600000,
            paper: {
              'expectedQuestionCount': 1,
              'sections': [
                {
                  'sectionId': 'a',
                  'name': 'A',
                  'questions': [
                    {'id': 'q1', 'setId': ''},
                  ],
                },
              ],
            },
          ),
          'parts': parts(
            index: 0,
            limitsMs: const [600000],
            remainingMs: 600000,
          ),
        },
      };
      for (final entry in cases.entries) {
        test(entry.key, () {
          expect(
            () => ServerMockPaper.decode(entry.value),
            throwsA(isA<ServerMockFormatException>()),
          );
        });
      }
    });
  });
}
