import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/home/application/tendencies_provider.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> seedInitialData(
    AppDatabase targetDb, {
    int readThenQuiz = 12,
    int quizFirst = 4,
    double practiceAcc = 0.68,
    double mockAcc = 0.54,
    double firstHalfAcc = 0.80,
    double secondHalfAcc = 0.76,
    bool includeMock = true,
    bool includeSpeed = false,
  }) async {
    const examId = 'exam_upcat';
    await targetDb.into(targetDb.exams).insertOnConflictUpdate(
          ExamsCompanion.insert(
            id: examId,
            code: 'UPCAT',
            name: 'UP College Admissions Test',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );

    await targetDb.into(targetDb.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'sub_1',
            examId: examId,
            name: 'Math',
            ordering: 1,
          ),
        );

    await targetDb.into(targetDb.topics).insertOnConflictUpdate(
          TopicsCompanion.insert(
            id: 'top_1',
            subjectId: 'sub_1',
            name: 'Algebra',
            ordering: 1,
          ),
        );

    final firstAttemptTime = DateTime.utc(2026, 5, 10);

    final totalLessons = readThenQuiz + quizFirst;
    for (var i = 0; i < totalLessons; i++) {
      final lessonId = 'les_$i';
      await targetDb.into(targetDb.lessons).insertOnConflictUpdate(
            LessonsCompanion.insert(
              id: lessonId,
              topicId: 'top_1',
              title: 'Lesson $i',
              summary: '',
              bodyJson: '{}',
              estimatedMinutes: 5,
            ),
          );

      final readAt = i < readThenQuiz
          ? firstAttemptTime.subtract(Duration(days: 2 + i))
          : firstAttemptTime.add(Duration(days: 1 + i));

      await targetDb.into(targetDb.lessonProgressLocal).insertOnConflictUpdate(
            LessonProgressLocalCompanion.insert(
              lessonId: lessonId,
              readAt: readAt,
            ),
          );
    }

    for (var i = 0; i < 14; i++) {
      await targetDb.into(targetDb.quizSessions).insertOnConflictUpdate(
            QuizSessionsCompanion.insert(
              id: 'sess_$i',
              userId: 'user_1',
              examId: examId,
              origin: 'practice',
              questionIdsJson: '[]',
              startedAt: DateTime.utc(2026, 5, 1 + i),
              completedAt: Value(DateTime.utc(2026, 5, 1 + i, 1)),
            ),
          );
    }

    const practiceTotal = 100;
    final practiceCorrect = (practiceTotal * practiceAcc).round();
    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < practiceTotal; i++) {
      final isCorrect = i < practiceCorrect;
      items.add({
        'questionId': 'q_$i',
        'questionVersion': 1,
        'chosenChoiceId': isCorrect ? 'a' : 'b',
        'correctChoiceId': 'a',
        'responseMs': includeSpeed ? (isCorrect ? 5000 : 12000) : 10000,
      });
    }

    for (var i = 0; i < practiceTotal; i++) {
      await targetDb.into(targetDb.questions).insertOnConflictUpdate(
            QuestionsCompanion.insert(
              id: 'q_$i',
              version: 1,
              examIdsJson: '["$examId"]',
              topicId: 'top_1',
              language: 'en',
              stem: 'Question $i',
              choicesJson:
                  '[{"id":"a","label":"A","text":"A","isCorrect":true},'
                  '{"id":"b","label":"B","text":"B","isCorrect":false}]',
              explanation: '',
            ),
          );
    }

    await targetDb.into(targetDb.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: 'att_practice',
            examId: examId,
            origin: const Value('practice'),
            startedAt: firstAttemptTime,
            completedAt: Value(firstAttemptTime.add(const Duration(hours: 1))),
            itemsJson: jsonEncode(items),
          ),
        );

    if (includeMock) {
      const mockTotal = 50;
      final mockQIds = List.generate(mockTotal, (i) => 'q_$i');
      final mockAnswers = <String, dynamic>{};

      const firstHalfCount = mockTotal ~/ 2;
      final firstHalfCorrectTarget = (firstHalfCount * firstHalfAcc).round();
      const secondHalfCount = mockTotal - firstHalfCount;
      final secondHalfCorrectTarget = (secondHalfCount * secondHalfAcc).round();

      for (var i = 0; i < mockTotal; i++) {
        final bool isCorrect;
        if (i < firstHalfCount) {
          isCorrect = i < firstHalfCorrectTarget;
        } else {
          isCorrect = (i - firstHalfCount) < secondHalfCorrectTarget;
        }
        mockAnswers['q_$i'] = {'selectedIndex': isCorrect ? 0 : 1, 'atSec': 10};
      }

      final submittedAt = DateTime.utc(2026, 5, 20);
      await targetDb.into(targetDb.mockAttempts).insertOnConflictUpdate(
            MockAttemptsCompanion.insert(
              id: 'mock_1',
              userId: 'user_1',
              examId: examId,
              blueprintId: 'bp_1',
              blueprintName: 'Mock 1',
              durationMinutes: 90,
              status: 'completed',
              strictMode: false,
              sampledQuestionsJson: jsonEncode([
                {
                  'sectionId': 'sec_1',
                  'name': 'Section 1',
                  'questionIds': mockQIds,
                }
              ]),
              answersJson: Value(jsonEncode(mockAnswers)),
              submittedAt: Value(submittedAt),
              startedAt: submittedAt.subtract(const Duration(minutes: 90)),
              lastFlushedAt: submittedAt,
              updatedAt: submittedAt,
            ),
          );
    }
  }

  setUp(() async {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );

    final prefsRepo = container.read(appPreferencesRepositoryProvider);
    await prefsRepo.setSelectedExamId('exam_upcat');
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('always four cards, in every data state', () async {
    await seedInitialData(db);
    final cards = await container.read(tendenciesProvider.future);
    expect(cards, hasLength(4));
    expect(
      cards.map((c) => c.kind).toSet(),
      TendencyKind.values.toSet(),
    );
  });

  test('a null signal becomes a prerequisite card, not a missing one',
      () async {
    // No mocks sat.
    await seedInitialData(db, includeMock: false);
    final cards = await container.read(tendenciesProvider.future);
    final stamina = cards.firstWhere((c) => c.kind == TendencyKind.stamina);

    expect(stamina.figures, isNull);
    expect(stamina.sentence, isNull);
    expect(stamina.leftLabel, isNotEmpty, reason: 'labels always show');
    expect(stamina.rightLabel, isNotEmpty);
    expect(stamina.unlockAction, 'Finish one full length mock');
  });

  test('measurable cards sort before blocked ones', () async {
    // Only howYouAnswer has data (speed dist data).
    final customDb = inMemoryDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      includeMock: false,
      includeSpeed: true,
      readThenQuiz: 0,
      quizFirst: 0,
    );

    final cards = await customContainer.read(tendenciesProvider.future);

    expect(cards.first.kind, TendencyKind.howYouAnswer);
    expect(cards.skip(1).every((c) => c.figures == null), isTrue);

    customContainer.dispose();
    await customDb.close();
  });

  test('worst first among measurable cards', () async {
    // pressure delta -0.18, stamina delta -0.04.
    final customDb = inMemoryDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      mockAcc: 0.50, // pressure delta -0.18
    );

    final cards = await customContainer.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.underPressure);

    customContainer.dispose();
    await customDb.close();
  });

  test('a gain sorts by size, not by sign', () async {
    // stamina delta +0.20, pressure delta -0.05.
    final customDb = inMemoryDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      mockAcc: 0.63, // pressure delta -0.05
      firstHalfAcc: 0.60,
      secondHalfAcc: 0.80, // stamina delta +0.20
    );

    final cards = await customContainer.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.stamina);

    customContainer.dispose();
    await customDb.close();
  });

  test('no user-facing string names the scheduler', () async {
    await seedInitialData(db);
    final cards = await container.read(tendenciesProvider.future);
    const banned = ['FSRS', 'stability', 'retention', 'algorithm', 'marks'];
    for (final card in cards) {
      final text = [
        card.heading,
        card.leftLabel,
        card.rightLabel,
        card.sentence ?? '',
        card.unlockAction,
      ].join(' ');
      for (final word in banned) {
        expect(text.toLowerCase(), isNot(contains(word.toLowerCase())));
      }
      expect(text, isNot(contains('—')));
    }
  });
}
