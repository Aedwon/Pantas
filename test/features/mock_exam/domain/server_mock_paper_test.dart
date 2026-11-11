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
}
