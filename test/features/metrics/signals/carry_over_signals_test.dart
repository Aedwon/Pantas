import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/counted_attempts.dart';
import 'package:pantas/features/metrics/signals/per_question_speed_signal.dart';
import 'package:pantas/features/metrics/signals/read_then_quiz_signal.dart';
import 'package:pantas/features/metrics/signals/test_mode_delta_signal.dart';

import '../../../helpers/in_memory_database.dart';

const upcat = 'exam_upcat';

// The student prepared for the CSE, then switched to UPCAT. UPCAT lists
// q_own and q_tag. q_cse_only is on the CSE alone.
void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    contentDb = ContentDatabase(NativeDatabase.memory());
    await seedContentTopicWithQuestions(
      contentDb,
      examId: upcat,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: ['q_own', 'q_tag'],
    );
    await _attempt(db, 'own', upcat, 'q_own', 4000);
    await _attempt(db, 'old_tag', 'exam_cse', 'q_tag', 8000);
    await _attempt(db, 'old_only', 'exam_cse', 'q_cse_only', 20000);
    await _attempt(db, 'old_mock', 'exam_cse', 'q_tag', 0, origin: 'mock');
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  AttemptScope scope({required bool carryOver}) =>
      AttemptScope(ContentRepository(contentDb), carryOver: carryOver);

  group('speed', () {
    test("on, the old exam's timed answers on shared questions count",
        () async {
      final result =
          await PerQuestionSpeedSignal(db, scope: scope(carryOver: true))
              .compute(window: _window(), examId: upcat);
      expect(result!.correctCount, 2);
      expect(result.averageMs, 6000);
    });

    test('off, only answers made under the current exam count', () async {
      final result =
          await PerQuestionSpeedSignal(db, scope: scope(carryOver: false))
              .compute(window: _window(), examId: upcat);
      expect(result!.correctCount, 1);
      expect(result.averageMs, 4000);
    });
  });

  group('pressure', () {
    test('practice side follows the choice; recorded mocks never count',
        () async {
      final on = await TestModeDeltaSignal(
        db,
        contentDb,
        scope: scope(carryOver: true),
      ).compute(window: _window(minSessions: 0), examId: upcat);
      expect(on!.practiceTotal, 2);

      final off = await TestModeDeltaSignal(
        db,
        contentDb,
        scope: scope(carryOver: false),
      ).compute(window: _window(minSessions: 0), examId: upcat);
      expect(off!.practiceTotal, 1);
    });
  });

  group('study', () {
    test('practiced topics follow the choice', () async {
      // Only the old exam touched topic_a through a carried question.
      await db.delete(db.attemptsLocal).go();
      await _attempt(db, 'old_tag', 'exam_cse', 'q_tag', 8000);
      final on = await ReadThenQuizSignal(
        db,
        contentDb,
        scope: scope(carryOver: true),
      ).compute(window: _window(minSessions: 0), examId: upcat);
      expect(on!.practicedTopicCount, 1);

      final off = await ReadThenQuizSignal(
        db,
        contentDb,
        scope: scope(carryOver: false),
      ).compute(window: _window(minSessions: 0), examId: upcat);
      expect(off!.practicedTopicCount, 0);
    });
  });
}

Future<void> _attempt(
  AppDatabase db,
  String id,
  String exam,
  String questionId,
  int ms, {
  String origin = 'today_topic',
}) {
  return db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: id,
          examId: exam,
          origin: Value(origin),
          startedAt: DateTime.utc(2026, 6),
          completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
          itemsJson: jsonEncode([
            {
              'questionId': questionId,
              'questionVersion': 1,
              'chosenChoiceId': 'c_a',
              'correctChoiceId': 'c_a',
              'responseMs': ms,
            },
          ]),
        ),
      );
}

ResolvedMetricsWindow _window({int minSessions = 7}) => ResolvedMetricsWindow(
      window: MetricsWindow.prepWindow,
      start: DateTime.utc(2026, 5, 11),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 7,
      minSessionCount: minSessions,
    );
