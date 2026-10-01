import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/progress/application/record_provider.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> seedContinuousHistory(DateTime start, int count) async {
    for (var i = 0; i < count; i++) {
      final day = DateTime(start.year, start.month, start.day + i, 12);
      await db.into(db.attemptsLocal).insert(
            AttemptsLocalCompanion.insert(
              id: 'history$i',
              examId: 'exam_upcat',
              origin: const Value('today_topic'),
              startedAt: day,
              completedAt: Value(day),
              itemsJson: '[]',
            ),
          );
    }
  }

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('weeks in counts from the first thing the student did', () async {
    // Account made 2026-03-01. First attempt 2026-07-12. Today 2026-08-02.
    final firstAttempt = DateTime(2026, 7, 12);
    final today = DateTime(2026, 8, 2);

    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: firstAttempt,
            completedAt: Value(firstAttempt.add(const Duration(minutes: 10))),
            itemsJson: jsonEncode([]),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        recordNowProvider.overrideWithValue(today),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.weeksIn, 3);
  });

  test('days active counts distinct local dates, not rows', () async {
    // Four attempts, two of them on the same day.
    final day1 = DateTime(2026, 7, 10);
    final day2 = DateTime(2026, 7, 11);
    final day3 = DateTime(2026, 7, 12);

    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: day1,
            completedAt: Value(day1.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([]),
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_2',
            examId: 'exam_upcat',
            startedAt: day1.add(const Duration(hours: 2)),
            completedAt: Value(day1.add(const Duration(hours: 2, minutes: 5))),
            itemsJson: jsonEncode([]),
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_3',
            examId: 'exam_upcat',
            startedAt: day2,
            completedAt: Value(day2.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([]),
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_4',
            examId: 'exam_upcat',
            startedAt: day3,
            completedAt: Value(day3.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([]),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.daysActive, 3);
  });

  test('a late-night answer counts for that day, not the next', () async {
    // One attempt at 23:40 local.
    final lateNight = DateTime(2026, 7, 10, 23, 40);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: lateNight,
            completedAt: Value(lateNight.add(const Duration(minutes: 10))),
            itemsJson: jsonEncode([]),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.daysActive, 1);
  });

  test('the streak start is last active minus the streak, less a day',
      () async {
    await seedContinuousHistory(DateTime(2026, 5, 12), 5);
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            id: const Value(1),
            current: const Value(5),
            longest: const Value(7),
            lastActiveDate: Value(DateTime(2026, 5, 16)),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.streakStartedOn, DateTime(2026, 5, 12));
  });

  for (final days in ['1,2,3,4,5', '1,2,3,4,5,6,7']) {
    test('streak start date is sound only with all seven: $days', () async {
      if (days == '1,2,3,4,5,6,7') {
        await seedContinuousHistory(DateTime(2026, 10), 5);
      }
      await db.into(db.accountPrefs).insert(
            AccountPrefsCompanion.insert(
              key: 'settings.study_days',
              value: days,
            ),
          );
      await db.into(db.streakLocal).insert(
            StreakLocalCompanion.insert(
              current: const Value(5),
              longest: const Value(7),
              lastActiveDate: Value(DateTime(2026, 10, 5)),
            ),
          );
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      final record = await container.read(recordProvider.future);
      expect(record.dayStreak, 5);
      expect(
        record.streakStartedOn,
        days == '1,2,3,4,5' ? null : DateTime(2026, 10),
      );
    });
  }

  Future<void> completeSession(
    String id,
    DateTime completedAt, {
    SessionOrigin origin = SessionOrigin.todayInterleaved,
    DateTime? startedAt,
  }) async {
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: id,
            examId: 'exam_upcat',
            origin: Value(origin.storageValue),
            startedAt: startedAt ?? completedAt,
            completedAt: Value(completedAt),
            itemsJson: '[]',
          ),
        );
  }

  test('returning to all seven days does not invent a weekend streak start',
      () async {
    final settings = DriftSettingsRepository(db);
    await settings.updateStudyDays(StudyDays(const [1, 2, 3, 4, 5]));
    final evaluator = StreakEvaluator(
      StreakRepository(db),
      studyDaysReader: () async =>
          (await settings.readUserSettings()).studyDays,
    );
    for (final day in [2, 5]) {
      final completedAt = DateTime(2026, 10, day, 12);
      await completeSession('day$day', completedAt);
      await evaluator.evaluate(
        origin: SessionOrigin.todayInterleaved,
        completedAt: completedAt,
      );
    }
    await settings.updateStudyDays(StudyDays.all);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    final record = await container.read(recordProvider.future);
    expect(record.dayStreak, 2);
    expect(record.streakStartedOn, isNull);
  });

  for (final days in [
    StudyDays.all,
    StudyDays(const [1, 2, 3, 4, 5]),
  ]) {
    test('consecutive completed days show the first day: ${days.storageValue}',
        () async {
      await DriftSettingsRepository(db).updateStudyDays(days);
      final evaluator = StreakEvaluator(
        StreakRepository(db),
        studyDaysReader: () async => days,
      );
      for (final day in [3, 4, 5]) {
        final completedAt = DateTime(2026, 10, day, 0, 5);
        await completeSession(
          'day$day',
          completedAt,
          startedAt: DateTime(2026, 10, day - 1, 23, 55),
        );
        await evaluator.evaluate(
          origin: SessionOrigin.todayInterleaved,
          completedAt: completedAt,
        );
      }
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      final record = await container.read(recordProvider.future);
      expect(record.dayStreak, 3);
      expect(record.streakStartedOn, DateTime(2026, 10, 3));
    });
  }

  test('a freeze does not create calendar continuity from other activity',
      () async {
    final streaks = StreakRepository(db);
    await streaks.writeSnapshot(
      current: 1,
      longest: 1,
      lastActiveDate: DateTime(2026, 10, 2),
      freezesRemaining: 1,
    );
    await completeSession('first', DateTime(2026, 10, 2, 12));
    await completeSession(
      'drill',
      DateTime(2026, 10, 3, 12),
      origin: SessionOrigin.drill,
    );
    // An unfinished eligible session also cannot establish continuity.
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'unfinished',
            examId: 'exam_upcat',
            origin: const Value('today_topic'),
            startedAt: DateTime(2026, 10, 3, 14),
            itemsJson: '[]',
          ),
        );
    await completeSession('last', DateTime(2026, 10, 4, 12));
    final evaluation = await StreakEvaluator(streaks).evaluate(
      origin: SessionOrigin.todayInterleaved,
      completedAt: DateTime(2026, 10, 4, 12),
    );
    expect(evaluation.freezeUsed, isTrue);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    final record = await container.read(recordProvider.future);
    expect(record.dayStreak, 2);
    expect(record.streakStartedOn, isNull);
  });

  test('no streak, no start date', () async {
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            id: const Value(1),
            lastActiveDate: Value(DateTime(2026, 5, 16)),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.streakStartedOn, isNull);
  });

  test('with no mock, best mock and the mock list are absent', () async {
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.bestMockPercent, isNull);
    expect(record.mocks, isEmpty);
  });

  test('the accuracy series is empty below two points', () async {
    // One week of attempts only.
    final week1 = DateTime(2026, 7, 13); // Monday
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: week1,
            completedAt: Value(week1.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([
              {
                'questionId': 'q1',
                'questionVersion': 1,
                'chosenChoiceId': 'c1',
                'correctChoiceId': 'c1',
                'responseMs': 1000,
              }
            ]),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.accuracySeries, isEmpty);
  });

  test('two weeks of attempts give two points', () async {
    final week1 = DateTime(2026, 7, 13); // Monday week 1
    final week2 = DateTime(2026, 7, 20); // Monday week 2

    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_upcat',
            startedAt: week1,
            completedAt: Value(week1.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([
              {
                'questionId': 'q1',
                'questionVersion': 1,
                'chosenChoiceId': 'c1',
                'correctChoiceId': 'c1',
                'responseMs': 1000,
              }
            ]),
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_2',
            examId: 'exam_upcat',
            startedAt: week2,
            completedAt: Value(week2.add(const Duration(minutes: 5))),
            itemsJson: jsonEncode([
              {
                'questionId': 'q2',
                'questionVersion': 1,
                'chosenChoiceId': 'c1',
                'correctChoiceId': 'c2',
                'responseMs': 1000,
              }
            ]),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.accuracySeries, hasLength(2));
  });

  test('assessment attempts count toward the totals', () async {
    // 21 items in itemsJson
    final items = List.generate(
      21,
      (i) => {
        'questionId': 'q_$i',
        'questionVersion': 1,
        'chosenChoiceId': 'c1',
        'correctChoiceId': 'c1',
        'responseMs': 1000,
      },
    );

    final start = DateTime(2026, 7, 10);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_assessment',
            examId: 'exam_upcat',
            origin: const Value('assessment'),
            startedAt: start,
            completedAt: Value(start.add(const Duration(minutes: 20))),
            itemsJson: jsonEncode(items),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.questionsAnswered, 21);
  });

  test('a forfeited mock counts its one recorded answer', () async {
    final taken = DateTime(2026, 9);
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: 'exam_upcat',
            blueprintId: 'bp_1',
            blueprintName: 'Full UPCAT Simulation',
            durationMinutes: 120,
            status: 'forfeited',
            strictMode: true,
            sampledQuestionsJson: jsonEncode([]),
            answersJson: Value(
              jsonEncode({
                'q1': {'selectedIndex': 0, 'atSec': 30},
              }),
            ),
            startedAt: taken,
            lastFlushedAt: taken,
            submittedAt: Value(taken.add(const Duration(minutes: 1))),
            updatedAt: taken,
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'mock_1',
            examId: 'exam_upcat',
            origin: const Value('mock'),
            startedAt: taken,
            completedAt: Value(taken.add(const Duration(minutes: 1))),
            itemsJson: jsonEncode([
              {
                'questionId': 'q1',
                'questionVersion': 1,
                'chosenChoiceId': 'c1',
                'correctChoiceId': 'c2',
                'responseMs': 0,
              },
            ]),
          ),
        );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);

    expect(record.questionsAnswered, 1);
    expect(record.mocks, isEmpty);
  });

  test('recorded mock answers are not counted twice', () async {
    final taken = DateTime(2026, 7, 12);
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: 'exam_upcat',
            blueprintId: 'bp_1',
            blueprintName: 'Full UPCAT Simulation',
            durationMinutes: 120,
            status: 'completed',
            strictMode: false,
            sampledQuestionsJson: jsonEncode([]),
            scoreRaw: const Value(3),
            scoreTotal: const Value(4),
            startedAt: taken,
            lastFlushedAt: taken,
            submittedAt: Value(taken),
            updatedAt: taken,
          ),
        );
    // The same mock's answers, recorded as an attempt for reviews.
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'mock_1',
            examId: 'exam_upcat',
            origin: const Value('mock'),
            startedAt: taken,
            completedAt: Value(taken),
            itemsJson: jsonEncode(
              List.generate(
                4,
                (i) => {
                  'questionId': 'q_$i',
                  'questionVersion': 1,
                  'chosenChoiceId': 'c1',
                  'correctChoiceId': 'c1',
                  'responseMs': 0,
                },
              ),
            ),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(record.questionsAnswered, 4);
  });

  test('mocks are newest first', () async {
    final older = DateTime(2026, 6);
    final newer = DateTime(2026, 7);

    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: 'exam_upcat',
            blueprintId: 'bp_1',
            blueprintName: 'Full UPCAT Simulation',
            durationMinutes: 120,
            status: 'completed',
            strictMode: false,
            sampledQuestionsJson: jsonEncode([]),
            scoreRaw: const Value(80),
            scoreTotal: const Value(100),
            startedAt: older,
            lastFlushedAt: older,
            submittedAt: Value(older),
            updatedAt: older,
          ),
        );

    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock_2',
            userId: 'local',
            examId: 'exam_upcat',
            blueprintId: 'bp_1',
            blueprintName: 'Full UPCAT Simulation',
            durationMinutes: 120,
            status: 'completed',
            strictMode: false,
            sampledQuestionsJson: jsonEncode([]),
            scoreRaw: const Value(90),
            scoreTotal: const Value(100),
            startedAt: newer,
            lastFlushedAt: newer,
            submittedAt: Value(newer),
            updatedAt: newer,
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    final record = await container.read(recordProvider.future);
    expect(
      record.mocks.first.takenOn.isAfter(record.mocks.last.takenOn),
      isTrue,
    );
  });
}
