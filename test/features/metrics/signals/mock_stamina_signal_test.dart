import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/mock_stamina_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compares first-half and second-half mock accuracy', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _content(db);
    await _mock(db);

    final result = await MockStaminaSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.firstHalfAccuracy, 0.5);
    expect(result.secondHalfAccuracy, 1);
    expect(result.delta, 0.5);
  });
}

Future<void> _content(AppDatabase db) async {
  await db.into(db.exams).insert(
        ExamsCompanion.insert(
          id: 'exam_cse',
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
        ),
      );
  await db.into(db.subjects).insert(
        SubjectsCompanion.insert(
          id: 'subject_1',
          examId: 'exam_cse',
          name: 'General',
          ordering: 1,
        ),
      );
  await db.into(db.topics).insert(
        TopicsCompanion.insert(
          id: 'topic_1',
          subjectId: 'subject_1',
          name: 'Topic',
          ordering: 1,
        ),
      );
  for (final id in ['q1', 'q2', 'q3', 'q4']) {
    await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: id,
            version: 1,
            examIdsJson: '["exam_cse"]',
            topicId: 'topic_1',
            language: 'en',
            stem: id,
            choicesJson: '''
[{"id":"a","label":"A","text":"A","isCorrect":true},{"id":"b","label":"B","text":"B","isCorrect":false}]
''',
            explanation: '',
          ),
        );
  }
}

Future<void> _mock(AppDatabase db) {
  final submittedAt = DateTime.utc(2026, 6);
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: 'm1',
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp',
          blueprintName: 'Mock',
          durationMinutes: 90,
          status: 'completed',
          strictMode: false,
          sampledQuestionsJson: '[{"sectionId":"s","name":"S",'
              '"questionIds":["q1","q2","q3","q4"]}]',
          answersJson: const Value(
            '{"q1":{"selectedIndex":0,"atSec":1},'
            '"q2":{"selectedIndex":1,"atSec":2},'
            '"q3":{"selectedIndex":0,"atSec":3},'
            '"q4":{"selectedIndex":0,"atSec":4}}',
          ),
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(const Duration(minutes: 90)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}

ResolvedMetricsWindow _window() => ResolvedMetricsWindow(
      window: MetricsWindow.prepWindow,
      start: DateTime.utc(2026, 5),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 14,
      minSessionCount: 14,
    );
