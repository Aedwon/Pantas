import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/progress/application/record_provider.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

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
