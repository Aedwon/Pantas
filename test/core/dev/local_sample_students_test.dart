import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/local_sample_students.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/rating_heuristic.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:pantas/features/roadmap/application/lesson_links_loader.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../helpers/in_memory_database.dart';

// A Saturday, so the last study day before it is a plain weekday.
final _today = DateTime(2026, 10, 31, 10);

/// Four subjects of two topics, each topic with four lessons and 25 questions.
Future<void> _seedContent(ContentDatabase db) async {
  await seedContentExam(db, examId: sampleExamId, code: 'CSE-P');
  var topicNumber = 0;
  for (var s = 0; s < 4; s++) {
    await seedContentSubject(
      db,
      subjectId: 'subject_$s',
      examId: sampleExamId,
      name: 'Subject $s',
      ordering: s,
    );
    for (var t = 0; t < 2; t++) {
      final topicId = 'topic_${topicNumber++}';
      await seedContentTopic(
        db,
        topicId: topicId,
        subjectId: 'subject_$s',
        ordering: t,
      );
      for (var l = 0; l < 4; l++) {
        await seedContentLesson(
          db,
          lessonId: '${topicId}_lesson_$l',
          topicId: topicId,
          ordering: l,
        );
      }
      for (var q = 0; q < 25; q++) {
        await seedContentQuestion(
          db,
          questionId: '${topicId}_q$q',
          topicId: topicId,
          examId: sampleExamId,
          lessonId: '${topicId}_lesson_${q % 4}',
        );
      }
    }
  }
}

void main() {
  // Some tests open a second database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late ContentDatabase content;

  setUp(() async {
    db = inMemoryDatabase();
    content = inMemoryContentDatabase();
    await _seedContent(content);
  });

  tearDown(() async {
    await db.close();
    await content.close();
  });

  Future<void> load(SampleStudent student, {DateTime? today}) =>
      loadSampleStudent(db, content, student, today: today ?? _today);

  DateTime midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  test('panel ids map to students', () {
    expect(SampleStudent.fromId('new'), SampleStudent.newStudent);
    expect(SampleStudent.fromId('steady'), SampleStudent.steady);
    expect(SampleStudent.fromId('behind'), SampleStudent.behind);
    expect(SampleStudent.fromId('examWeek'), SampleStudent.examWeek);
    expect(SampleStudent.fromId('nobody'), isNull);
    expect(SampleStudent.examWeek.id, 'examWeek');
  });

  test('the generator and the app agree on the heuristic version', () async {
    await load(SampleStudent.newStudent);
    final logs = await db.select(db.reviewLogs).get();
    expect(logs, isNotEmpty);
    expect(
      logs.every((l) => l.heuristicVersion == kRatingHeuristicVersion),
      isTrue,
    );
  });

  group('streak', () {
    const expected = {
      SampleStudent.newStudent: 1,
      SampleStudent.steady: 18,
      SampleStudent.behind: 0,
    };
    for (final entry in expected.entries) {
      test('${entry.key.id} reads ${entry.value}', () async {
        await load(entry.key);
        expect((await StreakRepository(db).read()).current, entry.value);
      });
    }

    test('exam week is at least 10', () async {
      await load(SampleStudent.examWeek);
      expect(
        (await StreakRepository(db).read()).current,
        greaterThanOrEqualTo(10),
      );
    });

    for (final student in [
      SampleStudent.newStudent,
      SampleStudent.steady,
      SampleStudent.examWeek,
    ]) {
      test('${student.id} equals what the app computes from its sessions',
          () async {
        await load(student);
        final stored = await StreakRepository(db).read();
        // Replay the sessions through the app's own streak rule.
        final scratch = inMemoryDatabase();
        addTearDown(scratch.close);
        final evaluator = StreakEvaluator(
          StreakRepository(scratch),
          studyDaysReader: () async => StudyDays(const [1, 2, 3, 4, 5, 6]),
        );
        final rows = await (db.select(db.attemptsLocal)
              ..where((a) => a.completedAt.isNotNull())
              ..orderBy([(a) => OrderingTerm.asc(a.completedAt)]))
            .get();
        for (final row in rows) {
          await evaluator.evaluate(
            origin: SessionOrigin.fromStorage(row.origin),
            completedAt: row.completedAt!,
          );
        }
        final replayed = await StreakRepository(scratch).read();
        expect(replayed.current, stored.current);
        expect(replayed.longest, stored.longest);
      });
    }

    test('a Sunday last study day still counts', () async {
      // Monday: yesterday was a Sunday, outside the study days.
      await load(SampleStudent.newStudent, today: DateTime(2026, 11, 2, 10));
      expect((await StreakRepository(db).read()).current, 1);
      await load(SampleStudent.steady, today: DateTime(2026, 11, 2, 10));
      expect((await StreakRepository(db).read()).current, 18);
    });
  });

  test('behind has reviews due before today and repeated misses', () async {
    await load(SampleStudent.behind);
    final states = await db.select(db.reviewStateLocal).get();
    final due = states.where((s) => s.due.isBefore(midnight(_today)));
    expect(due.length, greaterThan(10));
    expect(states.where((s) => s.lapses >= 2).length, greaterThanOrEqualTo(3));
    final last = (await StreakRepository(db).read()).lastActiveDate!;
    expect(midnight(_today).difference(midnight(last)).inDays, 6);
  });

  group('mocks', () {
    const counts = {
      SampleStudent.newStudent: 0,
      SampleStudent.steady: 1,
      SampleStudent.behind: 0,
      SampleStudent.examWeek: 4,
    };
    for (final entry in counts.entries) {
      test('${entry.key.id} has ${entry.value}', () async {
        await load(entry.key);
        final rows = await (db.select(db.mockAttempts)
              ..where((m) => m.status.equals('completed')))
            .get();
        expect(rows.length, entry.value);
        for (final row in rows) {
          expect(row.scoreRaw, lessThanOrEqualTo(row.scoreTotal!));
          expect(row.submittedAt, isNotNull);
          final sections =
              (jsonDecode(row.sectionResultsJson!) as Map)['sections'] as List;
          expect(
            sections.fold<int>(
              0,
              (sum, s) => sum + ((s as Map)['correct'] as int),
            ),
            row.scoreRaw,
          );
        }
      });
    }
  });

  group('onboarding answers', () {
    const examIn = {
      SampleStudent.newStudent: 120,
      SampleStudent.examWeek: 5,
    };
    for (final student in SampleStudent.values) {
      test('${student.id} is finished, as Aerol on CSE Professional', () async {
        await load(student);
        final prefs = AppPreferencesRepository(db);
        expect(await prefs.hasPassedAgeGate(), isTrue);
        expect(await prefs.hasCompletedOnboarding(), isTrue);
        expect(await prefs.selectedExamId(), sampleExamId);
        final settings = await DriftSettingsRepository(db).readUserSettings();
        expect(settings.name, 'Aerol');
        expect(settings.acceptedTermsAt, isNotNull);
        expect(
          settings.studyDays.weekdays,
          {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday,
          },
        );
        final days = settings.examDate!.daysUntil(_today)!;
        if (examIn[student] != null) expect(days, examIn[student]);
        expect(days, greaterThan(0));
      });
    }
  });

  group('the app reads each student', () {
    late ProviderContainer container;

    ProviderContainer open() => ProviderContainer(
          overrides: [
            lessonLinksProvider.overrideWith((ref) => {}),
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(content),
            nowProvider.overrideWithValue(() => _today),
            recordNowProvider.overrideWithValue(_today),
          ],
        );

    tearDown(() => container.dispose());

    for (final student in SampleStudent.values) {
      test('${student.id}: plan and record load without errors', () async {
        await load(student);
        // Keep the auto-disposed providers alive while they load.
        container = open()
          ..listen(roadmapTodayProvider(sampleExamId), (_, __) {})
          ..listen(recordProvider, (_, __) {});
        final today = await container.read(
          roadmapTodayProvider(sampleExamId).future,
        );
        expect(today.snapshot, isNotNull);
        final record = await container.read(recordProvider.future);
        expect(record.dayStreak, greaterThanOrEqualTo(0));
        expect(record.weeksIn, greaterThanOrEqualTo(1));
        switch (student) {
          case SampleStudent.newStudent:
            expect(record.questionsAnswered, 12);
            expect(record.lessonsRead, 1);
            expect(record.dayStreak, 1);
            expect(record.mocks, isEmpty);
          case SampleStudent.steady:
            expect(record.questionsAnswered, inInclusiveRange(350, 450));
            expect(record.lessonsRead, 30);
            expect(record.dayStreak, 18);
            expect(record.mocks.length, 1);
            expect(record.weeksIn, inInclusiveRange(3, 4));
          case SampleStudent.behind:
            expect(record.dayStreak, 0);
            expect(record.mocks, isEmpty);
            expect(record.weeksIn, inInclusiveRange(5, 6));
          case SampleStudent.examWeek:
            expect(record.dayStreak, greaterThanOrEqualTo(10));
            expect(record.mocks.length, 4);
            expect(record.weeksIn, inInclusiveRange(10, 11));
            // The mocks improve, so the best one is the last.
            expect(record.bestMockPercent, record.mocks.first.percent);
        }
      });
    }
  });

  test('accuracy follows the profile', () async {
    const target = {
      SampleStudent.steady: 0.75,
      SampleStudent.behind: 0.55,
      SampleStudent.examWeek: 0.80,
    };
    for (final entry in target.entries) {
      await load(entry.key);
      final logs = await db.select(db.reviewLogs).get();
      final right = logs.where((l) => l.isCorrect).length / logs.length;
      expect(right, closeTo(entry.value, 0.1), reason: entry.key.id);
    }
  });

  test('review logs and review state describe the same answers', () async {
    await load(SampleStudent.steady);
    final logs = await db.select(db.reviewLogs).get();
    final states = await db.select(db.reviewStateLocal).get();
    final logged = logs.map((l) => l.questionId).toSet();
    expect(logged.difference(states.map((s) => s.questionId).toSet()), isEmpty);
    expect(logs.map((l) => l.id).toSet().length, logs.length);
    for (final state in states) {
      final mine = logs.where((l) => l.questionId == state.questionId);
      if (mine.isEmpty) continue; // answered in the placement test only
      expect(state.reps, greaterThanOrEqualTo(mine.length));
    }
  });

  test('the same student twice gives the same records', () async {
    Future<Map<String, Object?>> snapshot() async {
      return {
        'logs': [
          for (final l in await (db.select(db.reviewLogs)
                ..orderBy([(l) => OrderingTerm.asc(l.id)]))
              .get())
            '${l.id}|${l.rating}|${l.isCorrect}|${l.durationMs}',
        ],
        'attempts': [
          for (final a in await (db.select(db.attemptsLocal)
                ..orderBy([(a) => OrderingTerm.asc(a.id)]))
              .get())
            '${a.id}|${a.origin}|${a.startedAt}|${a.itemsJson}',
        ],
        'reads': [
          for (final r in await (db.select(db.lessonProgressLocal)
                ..orderBy([(r) => OrderingTerm.asc(r.lessonId)]))
              .get())
            '${r.lessonId}|${r.readAt}',
        ],
      };
    }

    await load(SampleStudent.examWeek);
    final first = await snapshot();
    await load(SampleStudent.examWeek);
    expect(await snapshot(), first);
    expect((first['logs']! as List).length, greaterThan(100));
  });

  test('loading replaces the previous student', () async {
    await load(SampleStudent.examWeek);
    await load(SampleStudent.newStudent);
    expect(await db.select(db.mockAttempts).get(), isEmpty);
    expect((await db.select(db.attemptsLocal).get()).length, 2);
    expect((await StreakRepository(db).read()).current, 1);
  });

  test('a database with no content still gets the onboarding answers',
      () async {
    final empty = inMemoryContentDatabase();
    addTearDown(empty.close);
    await loadSampleStudent(
      db,
      empty,
      SampleStudent.steady,
      today: _today,
    );
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(await AppPreferencesRepository(db).selectedExamId(), sampleExamId);
  });
}
