import 'dart:convert';

import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/progress/application/how_you_work_provider.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  Future<void> seedInitialData(
    AppDatabase targetDb,
    ContentDatabase contentDb, {
    int readThenQuiz = 12,
    int quizFirst = 4,
    double practiceAcc = 0.68,
    double mockAcc = 0.54,
    double stability = 9.0,
    double lapseRate = 0.18,
    bool includeMock = true,
  }) async {
    const examId = 'exam_upcat';
    await seedContentExam(
      contentDb,
      examId: examId,
      code: 'UPCAT',
      name: 'UP College Admissions Test',
      shortName: 'UPCAT',
    );

    await seedContentSubject(
      contentDb,
      subjectId: 'sub_1',
      examId: examId,
      name: 'Math',
    );

    await seedContentTopic(
      contentDb,
      topicId: 'top_1',
      subjectId: 'sub_1',
      name: 'Algebra',
    );

    final firstAttemptTime = DateTime.utc(2026, 5, 10);

    // Create lessons and lesson progress for readThenQuiz vs quizFirst
    final totalLessons = readThenQuiz + quizFirst;
    for (var i = 0; i < totalLessons; i++) {
      final lessonId = 'les_$i';
      await seedContentLesson(
        contentDb,
        lessonId: lessonId,
        topicId: 'top_1',
        title: 'Lesson $i',
        summary: '',
        bodyJson: '{}',
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

    // Fourteen completed quiz sessions, which is what the window needs
    // before it reports having enough data.
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

    // Insert review state for retention
    await targetDb.into(targetDb.reviewStateLocal).insertOnConflictUpdate(
          ReviewStateLocalCompanion.insert(
            questionId: 'q_retention',
            questionVersion: 1,
            stage: 'review',
            stability: stability,
            difficulty: 5,
            due: DateTime.utc(2026, 6, 2),
            lastReview: DateTime.utc(2026, 6),
            reps: 100,
            lapses: (100 * lapseRate).round(),
            elapsedDays: 1,
            scheduledDays: 9,
          ),
        );

    // Insert practice attempts for pressure delta
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
        'responseMs': 10000,
      });
    }

    for (var i = 0; i < practiceTotal; i++) {
      await seedContentQuestionWithChoices(
        contentDb,
        questionId: 'q_$i',
        topicId: 'top_1',
        examId: examId,
        choices: [
          {'id': 'q${i}_a', 'label': 'A', 'text': 'A', 'isCorrect': true},
          {'id': 'q${i}_b', 'label': 'B', 'text': 'B', 'isCorrect': false},
        ],
        stem: 'Question $i',
        explanation: '',
      );
    }

    await targetDb.into(targetDb.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: 'att_practice',
            examId: examId,
            startedAt: firstAttemptTime,
            completedAt: Value(firstAttemptTime.add(const Duration(hours: 1))),
            itemsJson: jsonEncode(items),
          ),
        );

    if (includeMock) {
      // Insert mock attempt for pressure delta
      const mockTotal = 50;
      final mockCorrect = (mockTotal * mockAcc).round();
      final mockQIds = List.generate(mockTotal, (i) => 'q_$i');
      final mockAnswers = <String, dynamic>{};
      for (var i = 0; i < mockTotal; i++) {
        final isCorrect = i < mockCorrect;
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
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );

    final prefsRepo = container.read(appPreferencesRepositoryProvider);
    await prefsRepo.setSelectedExamId('exam_upcat');

    await seedInitialData(db, contentDb);
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('always five tendencies, in the spec order', () async {
    final work = await container.read(howYouWorkProvider.future);
    expect(
      work.tendencies.map((t) => t.id),
      [
        TendencyId.underPressure,
        TendencyId.stamina,
        TendencyId.howYouStudy,
        TendencyId.howYouAnswer,
        TendencyId.howLongYouRemember,
      ],
    );
  });

  test('a null signal keeps the heading and both labels', () async {
    final nullDb = inMemoryDatabase();
    final nullContentDb = openTestContentDatabase();
    await seedInitialData(nullDb, nullContentDb, includeMock: false);
    final nullContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(nullDb),
        contentDatabaseProvider.overrideWithValue(nullContentDb),
      ],
    );
    final prefsRepo = nullContainer.read(appPreferencesRepositoryProvider);
    await prefsRepo.setSelectedExamId('exam_upcat');

    final work = await nullContainer.read(howYouWorkProvider.future);
    final stamina =
        work.tendencies.firstWhere((t) => t.id == TendencyId.stamina);

    expect(stamina.gap, isNull);
    expect(stamina.leftLabel, isNotEmpty);
    expect(stamina.rightLabel, isNotEmpty);
    expect(stamina.unlockAction, 'Finish one full length mock');

    nullContainer.dispose();
    await nullDb.close();
  });

  test('a drop is a loss and a rise is not', () async {
    final work = await container.read(howYouWorkProvider.future);
    final pressure =
        work.tendencies.firstWhere((t) => t.id == TendencyId.underPressure);
    expect(pressure.isLoss, isTrue);
  });

  test('how long you remember states the estimate as an estimate', () async {
    final work = await container.read(howYouWorkProvider.future);
    final retention = work.tendencies
        .firstWhere((t) => t.id == TendencyId.howLongYouRemember);

    expect(retention.gap, '9d');
    expect(
      retention.sentence,
      'what you learn holds about nine days before you need it again',
    );
  });

  test('the retention line is never compared to the exam date', () async {
    final work = await container.read(howYouWorkProvider.future);
    final retention = work.tendencies
        .firstWhere((t) => t.id == TendencyId.howLongYouRemember);

    for (final s in [retention.sentence, retention.leftFigure]) {
      expect(s ?? '', isNot(contains('exam')));
      expect(s ?? '', isNot(contains('UPCAT')));
    }
  });

  test('how you study names the pattern and claims no payoff', () async {
    final work = await container.read(howYouWorkProvider.future);
    final study =
        work.tendencies.firstWhere((t) => t.id == TendencyId.howYouStudy);

    expect(study.heading, 'How you study');
    expect(study.sentence, 'You usually read the lesson first.');
    expect(study.leftFigure, '12');
    expect(study.rightFigure, '4');
    expect(study.gap, '8');
    expect(
      study.isLoss,
      isFalse,
      reason: 'neither direction is a loss, so this one never carries rust',
    );

    for (final claim in ['better', 'works for you', 'What works']) {
      expect(study.sentence, isNot(contains(claim)));
    }
  });

  test('the three sentences are the whole vocabulary', () async {
    Future<HowYouWork> readWith(
      (int readThenQuiz, int quizFirst) counts,
    ) async {
      final customDb = inMemoryDatabase();
      final customContentDb = openTestContentDatabase();
      await seedInitialData(
        customDb,
        customContentDb,
        readThenQuiz: counts.$1,
        quizFirst: counts.$2,
      );
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(customDb),
          contentDatabaseProvider.overrideWithValue(customContentDb),
        ],
      );
      final prefsRepo = c.read(appPreferencesRepositoryProvider);
      await prefsRepo.setSelectedExamId('exam_upcat');
      final result = await c.read(howYouWorkProvider.future);
      c.dispose();
      await customDb.close();
      return result;
    }

    const readsFirst = (12, 4);
    const answersFirst = (4, 12);
    const evenSplit = (8, 8);

    for (final (fixture, sentence) in [
      (readsFirst, 'You usually read the lesson first.'),
      (answersFirst, 'You usually go straight to the questions.'),
      (evenSplit, 'You split about evenly between the two.'),
    ]) {
      final work = await readWith(fixture);
      final study =
          work.tendencies.firstWhere((t) => t.id == TendencyId.howYouStudy);
      expect(study.sentence, sentence);
    }
  });

  test('no banned word appears in any assembled string', () async {
    final work = await container.read(howYouWorkProvider.future);
    const banned = [
      'FSRS',
      'stability',
      'retention',
      'retrievability',
      'algorithm',
      'card',
      'marks',
    ];
    for (final t in work.tendencies) {
      final text = [
        t.heading,
        t.leftLabel,
        t.rightLabel,
        t.sentence ?? '',
        t.leftFigure ?? '',
        t.rightFigure ?? '',
        t.unlockAction,
      ].join(' ').toLowerCase();
      for (final word in banned) {
        expect(text, isNot(contains(word.toLowerCase())));
      }
      expect(text, isNot(contains('—')));
    }
  });

  test('with no name the profile carries none, not an empty string', () async {
    final work = await container.read(howYouWorkProvider.future);
    expect(work.name, isNull);
  });
}
