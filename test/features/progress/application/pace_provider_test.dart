import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/progress/application/pace_provider.dart';
import 'package:cse_cet_reviewer/features/settings/application/settings_providers.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> seedData({
    required int totalLessons,
    required List<DateTime> readDates,
    ExamDate? examDate,
  }) async {
    const examId = 'exam_upcat';
    await seedTopicWithQuestions(
      db,
      examId: examId,
      topicId: 'topic_1',
      topicName: 'Topic 1',
      questionIds: [],
    );

    // Insert totalLessons into lessons table
    for (var i = 0; i < totalLessons; i++) {
      final lessonId = 'lesson_$i';
      await db.into(db.lessons).insertOnConflictUpdate(
            LessonsCompanion.insert(
              id: lessonId,
              topicId: 'topic_1',
              title: 'Lesson $i',
              summary: 'Summary $i',
              bodyJson: jsonEncode([]),
              estimatedMinutes: 5,
              ordering: Value(i),
            ),
          );
    }

    // Insert read dates into lesson_progress_local
    for (var i = 0; i < readDates.length; i++) {
      final lessonId = 'lesson_$i';
      await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
            LessonProgressLocalCompanion.insert(
              lessonId: lessonId,
              readAt: readDates[i],
              syncState: const Value('synced'),
            ),
          );
    }

    // Set active exam focus
    final prefsRepo = container.read(appPreferencesRepositoryProvider);
    await prefsRepo.setSelectedExamId(examId);

    // Set exam date if provided
    if (examDate != null) {
      final settingsRepo = container.read(settingsRepositoryProvider);
      await settingsRepo.updateExamDate(examDate, today: DateTime.now());
    }
  }

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('counts lessons read against the exam total', () async {
    final now = DateTime.now();
    final readDates = List.generate(
      41,
      (i) => now.subtract(Duration(days: 14 - (i % 7))),
    );
    await seedData(totalLessons: 96, readDates: readDates);

    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsRead, 41);
    expect(pace.lessonsTotal, 96);
  });

  test('a month-precision date yields no day count', () async {
    final now = DateTime.now();
    final readDates = List.generate(
      41,
      (i) => now.subtract(Duration(days: 14 - (i % 7))),
    );
    await seedData(
      totalLessons: 96,
      readDates: readDates,
      examDate: ExamDate.inMonth(year: 2026, month: 10),
    );

    final pace = await container.read(paceProvider.future);
    expect(pace!.daysLeft, isNull);
    expect(pace.daysPastExam, isNull);
  });

  test('no date at all yields no day count', () async {
    final now = DateTime.now();
    final readDates = List.generate(
      41,
      (i) => now.subtract(Duration(days: 14 - (i % 7))),
    );
    await seedData(totalLessons: 96, readDates: readDates);

    final pace = await container.read(paceProvider.future);
    expect(pace!.daysLeft, isNull);
  });

  test('below the sample floor there is no rate', () async {
    // First lesson read 2 days ago.
    final now = DateTime.now();
    await seedData(
      totalLessons: 96,
      readDates: [now.subtract(const Duration(days: 2))],
    );

    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, isNull);
    expect(pace.daysPastExam, isNull);
  });

  test('the rate is measured over 28 days, not over all time', () async {
    // 15 lessons read 90 days ago, 3 read in the last 28.
    final now = DateTime.now();
    final readDates = [
      ...List.generate(15, (i) => now.subtract(const Duration(days: 90))),
      ...List.generate(3, (i) => now.subtract(const Duration(days: 10))),
    ];
    await seedData(totalLessons: 96, readDates: readDates);

    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, 1);
  });

  test('a rate that finishes in time reports no overshoot', () async {
    // 55 remaining (96 total, 41 read), 8 a week, 60 days left.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final readDates = [
      ...List.generate(9, (i) => now.subtract(const Duration(days: 60))),
      ...List.generate(32, (i) => now.subtract(const Duration(days: 14))),
    ];
    await seedData(
      totalLessons: 96,
      readDates: readDates,
      examDate: ExamDate.onDay(today.add(const Duration(days: 60))),
    );

    final pace = await container.read(paceProvider.future);
    expect(pace!.daysPastExam, isNull);
    expect(pace.rateToFinishInTime, isNull);
  });

  test('a rate that finishes late reports the overshoot and the fix', () async {
    // 55 remaining (96 total, 41 read), 3 a week, 120 days left.
    // 55/3 = 18.33 weeks = 128.3 days, so 9 days past.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final readDates = [
      ...List.generate(29, (i) => now.subtract(const Duration(days: 60))),
      ...List.generate(12, (i) => now.subtract(const Duration(days: 14))),
    ];
    await seedData(
      totalLessons: 96,
      readDates: readDates,
      examDate: ExamDate.onDay(today.add(const Duration(days: 120))),
    );

    final pace = await container.read(paceProvider.future);
    expect(pace!.daysPastExam, 9);
    expect(pace.rateToFinishInTime, 4);
  });

  test('a rate of zero never divides by zero', () async {
    // Nothing read in 28 days (41 read 60 days ago).
    final now = DateTime.now();
    final readDates = List.generate(
      41,
      (i) => now.subtract(const Duration(days: 60)),
    );
    await seedData(totalLessons: 96, readDates: readDates);

    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, 0);
    expect(pace.daysPastExam, isNull);
    expect(pace.rateToFinishInTime, isNull);
  });

  test('nothing on this reading is a score', () async {
    await seedData(totalLessons: 96, readDates: []);
    final pace = await container.read(paceProvider.future);
    // A guard against the field this section is forbidden to grow.
    expect(
      pace!.toString(),
      isNot(contains('score')),
      reason: 'Your pace stays arithmetic and never projects a score',
    );
  });
}
