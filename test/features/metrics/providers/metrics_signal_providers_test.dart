import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/metrics_signal_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signal registry exposes exactly the 13 locked measured signals', () {
    expect(metricsSignalRegistry.keys.toSet(), SignalKey.values.toSet());
    expect(metricsSignalRegistry, hasLength(13));
  });

  test('metricsSignalProvider resolves a signal through appDatabaseProvider',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _content(db);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson_1',
            readAt: DateTime.utc(2026, 6),
          ),
        );
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 'session_1',
            userId: 'user_1',
            examId: 'exam_cse',
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
          ),
        );
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      metricsSignalProvider(
        MetricsSignalRequest(
          signal: SignalKey.coverageBreadth,
          window: MetricsWindow.allTime,
          examId: 'exam_cse',
          now: DateTime.utc(2026, 6, 10),
        ),
      ).future,
    );

    expect(result?.value, isA<CoveragePct>());
    expect((result!.value! as CoveragePct).percent, 1);
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
  await db.into(db.lessons).insert(
        LessonsCompanion.insert(
          id: 'lesson_1',
          topicId: 'topic_1',
          title: 'Lesson',
          summary: '',
          bodyJson: '{}',
          estimatedMinutes: 5,
        ),
      );
}
