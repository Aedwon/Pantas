import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('signal registry exposes exactly the 13 locked measured signals', () {
    expect(metricsSignalRegistry.keys.toSet(), SignalKey.values.toSet());
    expect(metricsSignalRegistry, hasLength(13));
  });

  test('only tendency requests bypass the floor and keep separate cache keys',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final contentDb = openTestContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    final now = DateTime.utc(2026, 6, 10);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'attempt',
            examId: 'exam_cse',
            startedAt: now,
            completedAt: Value(now),
            itemsJson: '[{"questionId":"a","questionVersion":1,'
                '"chosenChoiceId":"a","correctChoiceId":"a","responseMs":1000},'
                '{"questionId":"b","questionVersion":1,'
                '"chosenChoiceId":"a","correctChoiceId":"b",'
                '"responseMs":2000}]',
          ),
        );
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    addTearDown(c.dispose);
    Future<Object?> read(SignalKey key, {required bool forTendency}) async =>
        (await c.read(
          metricsSignalProvider(
            MetricsSignalRequest(
              signal: key,
              window: MetricsWindow.prepWindow,
              examId: 'exam_cse',
              now: now,
              forTendency: forTendency,
            ),
          ).future,
        ))
            ?.value;
    final speed = await read(SignalKey.perQuestionSpeed, forTendency: true);
    expect(speed, isA<LatencyDistribution>());
    expect((speed! as LatencyDistribution).correctCount, 1);
    expect(await read(SignalKey.perQuestionSpeed, forTendency: false), isNull);
    // Even an erroneous tendency flag cannot bypass either work-hour signal.
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 'session',
            userId: 'user',
            examId: 'exam_cse',
            origin: 'practice',
            questionIdsJson: '[]',
            currentIndex: const Value(2),
            correctCount: const Value(1),
            startedAt: now,
            completedAt: Value(now),
          ),
        );
    expect(await read(SignalKey.timeOfDay, forTendency: true), isNull);
    expect(await read(SignalKey.sessionShape, forTendency: true), isNull);
  });

  test('metricsSignalProvider resolves a signal through appDatabaseProvider',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final contentDb = openTestContentDatabase();
    addTearDown(db.close);
    await _content(contentDb);
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
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

Future<void> _content(ContentDatabase contentDb) async {
  await seedContentExam(
    contentDb,
    examId: 'exam_cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );
  await seedContentSubject(
    contentDb,
    subjectId: 'subject_1',
    examId: 'exam_cse',
    name: 'General',
  );
  await seedContentTopic(
    contentDb,
    topicId: 'topic_1',
    subjectId: 'subject_1',
    name: 'Topic',
  );
  await seedContentLesson(
    contentDb,
    lessonId: 'lesson_1',
    topicId: 'topic_1',
    title: 'Lesson',
    summary: '',
    bodyJson: '{}',
  );
}
