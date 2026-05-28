import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/coverage_breadth_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/difficulty_calibration_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/read_then_quiz_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/retention_shape_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/subject_affinity_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/test_mode_delta_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await _content(db);
  });

  tearDown(() => db.close());

  test('subject affinity groups accuracy and speed by subject', () async {
    await _attempt(db);

    final result = await SubjectAffinitySignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.subjects['Verbal']?.total, 2);
    expect(result.subjects['Verbal']?.accuracy, 0.5);
    expect(result.subjects['Verbal']?.averageMs, 10000);
  });

  test('test mode delta compares mock and practice accuracy on matched topics',
      () async {
    await _attempt(db);
    await _mock(db);

    final result = await TestModeDeltaSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.practiceAccuracy, 0.5);
    expect(result.mockAccuracy, 1);
    expect(result.delta, 0.5);
  });

  test('difficulty calibration buckets timing and correctness by difficulty',
      () async {
    await _attempt(db);
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q1',
            questionVersion: 1,
            stage: 'review',
            stability: 10,
            difficulty: 7,
            due: DateTime.utc(2026, 6, 2),
            lastReview: DateTime.utc(2026, 6),
            reps: 3,
            lapses: 0,
            elapsedDays: 1,
            scheduledDays: 10,
          ),
        );

    final result = await DifficultyCalibrationSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.points.single.difficulty, 7);
    expect(result.points.single.averageMs, 8000);
    expect(result.points.single.accuracy, 1);
  });

  test('read then quiz ratio compares lesson read time to first topic attempt',
      () async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson_1',
            readAt: DateTime.utc(2026, 5, 31),
          ),
        );
    await _attempt(db);

    final result = await ReadThenQuizSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.readThenQuizCount, 1);
    expect(result.quizFirstCount, 0);
    expect(result.ratio, 1);
  });

  test('retention shape computes average stability and lapse rate', () async {
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q1',
            questionVersion: 1,
            stage: 'review',
            stability: 10,
            difficulty: 7,
            due: DateTime.utc(2026, 6, 2),
            lastReview: DateTime.utc(2026, 6),
            reps: 4,
            lapses: 1,
            elapsedDays: 1,
            scheduledDays: 10,
          ),
        );

    final result = await RetentionShapeSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.averageStability, 10);
    expect(result.lapseRate, 0.25);
  });

  test('coverage breadth counts topics with at least one read lesson',
      () async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson_1',
            readAt: DateTime.utc(2026, 5, 31),
          ),
        );

    final result = await CoverageBreadthSignal(db).compute(
      window: _allTime(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.coveredTopics, 1);
    expect(result.totalTopics, 2);
    expect(result.percent, 0.5);
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
          id: 'subject_v',
          examId: 'exam_cse',
          name: 'Verbal',
          ordering: 1,
        ),
      );
  for (final topic in ['topic_1', 'topic_2']) {
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: topic,
            subjectId: 'subject_v',
            name: topic,
            ordering: topic == 'topic_1' ? 1 : 2,
          ),
        );
  }
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
  for (final id in ['q1', 'q2']) {
    await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: id,
            version: 1,
            examIdsJson: '["exam_cse"]',
            topicId: 'topic_1',
            language: 'en',
            stem: id,
            choicesJson: '[{"id":"a","label":"A","text":"A",'
                '"isCorrect":true},{"id":"b","label":"B","text":"B",'
                '"isCorrect":false}]',
            explanation: '',
          ),
        );
  }
}

Future<void> _attempt(AppDatabase db) {
  return db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'attempt_1',
          examId: 'exam_cse',
          startedAt: DateTime.utc(2026, 6),
          completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
          itemsJson: '[{"questionId":"q1","questionVersion":1,'
              '"chosenChoiceId":"a","correctChoiceId":"a","responseMs":8000},'
              '{"questionId":"q2","questionVersion":1,'
              '"chosenChoiceId":"b","correctChoiceId":"a",'
              '"responseMs":12000}]',
        ),
      );
}

Future<void> _mock(AppDatabase db) {
  final submittedAt = DateTime.utc(2026, 6, 2);
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: 'mock_1',
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp',
          blueprintName: 'Mock',
          durationMinutes: 90,
          status: 'completed',
          strictMode: false,
          sampledQuestionsJson:
              '[{"sectionId":"s","name":"S","questionIds":["q1","q2"]}]',
          answersJson: const Value(
            '{"q1":{"selectedIndex":0,"atSec":1},'
            '"q2":{"selectedIndex":0,"atSec":2}}',
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

ResolvedMetricsWindow _allTime() => ResolvedMetricsWindow(
      window: MetricsWindow.allTime,
      start: null,
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 1,
      minSessionCount: 1,
    );
