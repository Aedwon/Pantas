import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

Map<String, Object?> result({bool open = true, bool pro = false}) => {
      'mockId': 'MockResult000001',
      'examId': 'exam_cse_pro',
      'serverNow': 2000,
      'accessRecheckAt': null,
      'startedAt': 1000,
      'submittedAt': 2000,
      'durationMs': 1000,
      'limitMs': 3600000,
      'strict': false,
      'endedBy': 'student',
      'score': {
        'correct': 1,
        'answered': 1,
        'wrong': 0,
        'blank': 1,
        'total': 2,
      },
      'sections': [
        {
          'sectionId': 's',
          'name': 'Paper',
          'correct': 1,
          'answered': 1,
          'wrong': 0,
          'blank': 1,
          'total': 2,
        }
      ],
      'canReview': open,
      'proCovered': pro,
      'reviewUntil': 2592002000,
      if (open)
        'paper': {
          'expectedQuestionCount': 2,
          'sections': [
            {
              'sectionId': 's',
              'name': 'Paper',
              'questions': [
                {'id': 'a', 'setId': 'set'},
                {'id': 'b', 'setId': 'set'},
              ],
            }
          ],
        },
      if (open)
        'answers': [
          {
            'questionId': 'a',
            'chosen': 'a',
            'correct': true,
            'answeredAt': 2000,
          }
        ],
      if (pro)
        'notes': {
          'a': {
            'missReason': 'misread',
            'blankReason': null,
            'reasonNote': 'Read carefully',
          },
        },
    };
void main() {
  test('verified result callable returns exact score, paper and paid note',
      () async {
    final api = ServerMockApi((name, data) async {
      expect(name, 'getMockResults');
      expect(data, {'mockId': 'MockResult000001'});
      return result(pro: true);
    });
    final out = await api.results('MockResult000001');
    expect(out.results.percent, 50);
    expect(out.paper!.questionIds, ['a', 'b']);
    expect(out.notes['a']?.reasonNote, 'Read carefully');
  });
  test('locked results keep counts without reconstructing a paper', () async {
    final out = await ServerMockApi((_, __) async => result(open: false))
        .results('MockResult000001');
    expect(out.paper, isNull);
    expect(out.canReview, isFalse);
    expect(out.results.scoreTotal, 2);
  });
  test('Free responses cannot retain paid notes or locked paper', () async {
    for (final raw in [
      result()..['notes'] = {'a': <String, Object?>{}},
      result(open: false)..['paper'] = <String, Object?>{},
    ]) {
      await expectLater(
        ServerMockApi((_, __) async => raw).results('MockResult000001'),
        throwsA(isA<ServerMockFormatException>()),
      );
    }
  });
  test('impossible counts and mismatched result identity fail closed',
      () async {
    for (final raw in [
      result()
        ..['score'] = {
          'correct': 3,
          'answered': 1,
          'wrong': 0,
          'blank': 1,
          'total': 2,
        },
      result()..['mockId'] = 'MockResult000002',
    ]) {
      await expectLater(
        ServerMockApi((_, __) async => raw).results('MockResult000001'),
        throwsA(isA<ServerMockFormatException>()),
      );
    }
  });
  test('paid note callable sends the original question and reason fields',
      () async {
    final api = ServerMockApi((name, data) async {
      expect(name, 'updateMockReview');
      expect(data, {
        'mockId': 'MockResult000001',
        'questionId': 'a',
        'missReason': null,
        'blankReason': 'didNotKnow',
        'reasonNote': 'Review this',
      });
      return {'stored': true};
    });
    await api.saveReview(
      mockId: 'MockResult000001',
      questionId: 'a',
      blankReason: 'didNotKnow',
      reasonNote: 'Review this',
    );
  });
}
