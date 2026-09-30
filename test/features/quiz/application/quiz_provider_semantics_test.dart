import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  const examId = 'exam_cse_pro';
  const request = QuizPreparationRequest(
    userId: quizLocalUserId,
    examId: examId,
  );

  test('daily intro writes do not change cached Today preparation', () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    final now = DateTime(2026, 9, 9, 9);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 8; i++) 'a_$i'],
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    final preparer = container.read(todayQuizPreparerProvider);
    final first = await preparer.prepare(request);
    await container.read(newCardIntroRepositoryProvider).incrementForDay(
          userId: quizLocalUserId,
          examId: examId,
          day: now,
          by: 3,
        );
    final second = await preparer.prepare(request);

    expect(identical(first, second), isTrue);
    expect(second.stamp.historyRevision, first.stamp.historyRevision);
    expect(second.plan.freshCount, first.plan.freshCount);
  });

  test('scope exclusion mutation rebuilds cached Today preparation', () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 4; i++) 'a_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_b',
      topicName: 'B',
      questionIds: [for (var i = 0; i < 4; i++) 'b_$i'],
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => DateTime(2026, 9, 9, 9)),
      ],
    );
    addTearDown(container.dispose);

    final preparer = container.read(todayQuizPreparerProvider);
    final first = await preparer.prepare(request);
    await container.read(customTrackRepositoryProvider).setExcluded(
      examId: examId,
      topicIds: {'topic_b'},
    );
    final second = await preparer.prepare(request);

    expect(identical(first, second), isFalse);
    expect(second.stamp.scopeToken, isNot(first.stamp.scopeToken));
    expect(
      second.stamp.topicExclusionToken,
      isNot(first.stamp.topicExclusionToken),
    );
    expect(second.plan.questions, isNotEmpty);
    expect(
      second.plan.questions.map((question) => question.topicId).toSet(),
      {'topic_a'},
    );
  });

  test('named-topic interleaved Today keeps the E05 70/30 composition',
      () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 10; i++) 'a_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_b',
      topicName: 'B',
      questionIds: [for (var i = 0; i < 10; i++) 'b_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_c',
      topicName: 'C',
      questionIds: [for (var i = 0; i < 10; i++) 'c_$i'],
    );
    await db.batch((batch) {
      batch
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.sessionOrdering,
            value: 'interleavedTail',
          ),
          mode: InsertMode.insertOrReplace,
        )
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.sessionLengthKey,
            value: '10',
          ),
          mode: InsertMode.insertOrReplace,
        )
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: 'quiz_new_card_cap',
            value: '30',
          ),
          mode: InsertMode.insertOrReplace,
        );
    });
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => DateTime(2026, 9, 9, 9)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(customTrackRepositoryProvider).setExcluded(
      examId: examId,
      topicIds: {'topic_c'},
    );

    final prepared = await container.read(todayQuizPreparerProvider).prepare(
          const QuizPreparationRequest(
            userId: quizLocalUserId,
            examId: examId,
            topicId: 'topic_a',
          ),
        );
    final topicIds = prepared.plan.questions
        .map((question) => question.topicId)
        .toList(growable: false);

    expect(topicIds, hasLength(10));
    expect(topicIds.where((topic) => topic == 'topic_a'), hasLength(7));
    expect(topicIds.where((topic) => topic == 'topic_b'), hasLength(3));
    expect(topicIds, isNot(contains('topic_c')));
  });

  test('named-topic blocked Today stays inside the requested topic', () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 10; i++) 'a_blocked_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_b',
      topicName: 'B',
      questionIds: [for (var i = 0; i < 10; i++) 'b_blocked_$i'],
    );
    await db.batch((batch) {
      batch
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.sessionOrdering,
            value: 'blocked',
          ),
          mode: InsertMode.insertOrReplace,
        )
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.sessionLengthKey,
            value: '10',
          ),
          mode: InsertMode.insertOrReplace,
        )
        ..insert(
          db.accountPrefs,
          AccountPrefsCompanion.insert(
            key: 'quiz_new_card_cap',
            value: '20',
          ),
          mode: InsertMode.insertOrReplace,
        );
    });
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => DateTime(2026, 9, 9, 9)),
      ],
    );
    addTearDown(container.dispose);

    final prepared = await container.read(todayQuizPreparerProvider).prepare(
          const QuizPreparationRequest(
            userId: quizLocalUserId,
            examId: examId,
            topicId: 'topic_a',
          ),
        );

    expect(prepared.plan.questions, hasLength(10));
    expect(
      prepared.plan.questions.map((question) => question.topicId).toSet(),
      {'topic_a'},
    );
  });

  test('prepared Today launch persists actual launch time, not preparedAt',
      () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 5; i++) 'a_$i'],
    );
    var now = DateTime(2026, 9, 9, 9);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    final prepared =
        await container.read(todayQuizPreparerProvider).prepare(request);
    expect(prepared.preparedAt, DateTime(2026, 9, 9, 9));
    now = DateTime(2026, 9, 9, 10);

    final result = await container
        .read(quizLaunchCoordinatorProvider)
        .launchToday(request, prepared: prepared);

    expect(result, isA<QuizLaunchStarted>());
    final session = (result as QuizLaunchStarted).session;
    expect(session.startedAt, now);
    expect(session.startedAt, isNot(prepared.preparedAt));
    final rows = await db.select(db.quizSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.startedAt, now);
  });

  test(
      'Settings ordering beats conflicting legacy value through one persisted '
      'Today launch', () async {
    final db = inMemoryDatabase();
    await AssessmentRepository(db)
        .saveResult(examId, DateTime(2026, 9, 9), const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDate,
            value: '2026-09-10',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.examDatePrecision,
            value: 'day',
          ),
        );
    final contentDb = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(contentDb.close);
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_a',
      topicName: 'A',
      questionIds: [for (var i = 0; i < 5; i++) 'a_$i'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      topicId: 'topic_b',
      topicName: 'B',
      questionIds: [for (var i = 0; i < 5; i++) 'b_$i'],
    );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.sessionOrdering,
            value: 'fullyMixed',
          ),
        );
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(
            key: QuizPreferencesRepository.interleavedTodayKey,
            value: 'false',
          ),
        );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        nowProvider.overrideWithValue(() => DateTime(2026, 9, 9, 9)),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(quizLaunchCoordinatorProvider)
        .launchToday(request);

    expect(result, isA<QuizLaunchStarted>());
    final session = (result as QuizLaunchStarted).session;
    expect(session.questions, hasLength(10));
    for (var i = 1; i < session.questions.length; i++) {
      expect(
        session.questions[i].topicId,
        isNot(session.questions[i - 1].topicId),
      );
    }
    final rows = await db.select(db.quizSessions).get();
    expect(rows, hasLength(1));
    final persistedIds =
        (jsonDecode(rows.single.questionIdsJson) as List).cast<String>();
    expect(
      persistedIds,
      session.questions.map((question) => question.id).toList(),
    );
  });
}
