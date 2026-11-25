import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';

void main() {
  final started = DateTime.utc(2026, 11, 26, 3);

  AssessmentProgress sample() => AssessmentProgress(
        examId: 'e1',
        attemptId: 'a1',
        startedAt: started,
        questionIds: const ['q1', 'q2', 'q3'],
        picks: const {'q1': 'c1', 'q3': 'c9'},
        responseMs: const {'q1': 1200},
      );

  test('counts only picks for questions still in the list', () {
    final progress = AssessmentProgress(
      examId: 'e1',
      attemptId: 'a1',
      startedAt: started,
      questionIds: const ['q1', 'q2'],
      picks: const {'q1': 'c1', 'gone': 'c2'},
    );
    expect(progress.answered, 1);
    expect(progress.total, 2);
  });

  test('round trips through JSON', () {
    final back = AssessmentProgress.tryParse(sample().encode());
    expect(back, isNotNull);
    expect(back!.examId, 'e1');
    expect(back.attemptId, 'a1');
    expect(back.startedAt, started);
    expect(back.questionIds, ['q1', 'q2', 'q3']);
    expect(back.picks, {'q1': 'c1', 'q3': 'c9'});
    expect(back.responseMs, {'q1': 1200});
  });

  test('damaged or empty JSON reads as no progress', () {
    expect(AssessmentProgress.tryParse('not json'), isNull);
    expect(AssessmentProgress.tryParse('{"examId":1}'), isNull);
    expect(
      AssessmentProgress.tryParse(
        '{"examId":"e1","attemptId":"a","startedAt":"2026-11-26T03:00:00Z",'
        '"questionIds":[],"picks":{},"responseMs":{}}',
      ),
      isNull,
    );
  });

  test('keepOnly drops ids and picks that left the bank', () {
    final kept = sample().keepOnly({'q1', 'q2'});
    expect(kept!.questionIds, ['q1', 'q2']);
    expect(kept.picks, {'q1': 'c1'});
    expect(kept.responseMs, {'q1': 1200});
    expect(sample().keepOnly({'zzz'}), isNull);
  });

  test('firstUnansweredIndex opens the first question with no pick', () {
    expect(sample().firstUnansweredIndex, 1);
    final all = AssessmentProgress(
      examId: 'e1',
      attemptId: 'a1',
      startedAt: started,
      questionIds: const ['q1'],
      picks: const {'q1': 'c1'},
    );
    expect(all.firstUnansweredIndex, isNull);
  });
}
