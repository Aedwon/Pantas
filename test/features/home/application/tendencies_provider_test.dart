import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/tendencies_provider.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';
import 'package:pantas/features/metrics/providers/metrics_signal_providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

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
    double firstHalfAcc = 0.80,
    double secondHalfAcc = 0.76,
    bool includeMock = true,
    bool includeSpeed = false,
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
        'responseMs': includeSpeed
            ? (isCorrect ? 5000 : 12000) + (i.isEven ? -100 : 100)
            : 10000,
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
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );

    final prefsRepo = container.read(appPreferencesRepositoryProvider);
    await prefsRepo.setSelectedExamId('exam_upcat');
  });

  for (final includeMock in [false, true]) {
    test('pressure uses American spelling with mock: $includeMock', () async {
      await seedInitialData(db, contentDb, includeMock: includeMock);
      final cards = await container.read(tendenciesProvider.future);
      expect(
        cards.firstWhere((c) => c.kind == TendencyKind.underPressure).leftLabel,
        'practicing',
      );
    });
  }

  test('figures appear below 14 sessions without an unsupported sentence',
      () async {
    await seedInitialData(db, contentDb, readThenQuiz: 1, quizFirst: 1);
    await db.delete(db.quizSessions).go();
    final cards = await container.read(tendenciesProvider.future);
    expect(cards.every((card) => card.figures != null), isTrue);
    final study = cards.firstWhere((c) => c.kind == TendencyKind.howYouStudy);
    expect(study.sentence, isNull);
  });

  test('unlock actions name only the missing pressure and speed side',
      () async {
    await seedInitialData(db, contentDb);
    await db.delete(db.attemptsLocal).go();
    final cards = await container.read(tendenciesProvider.future);
    final pressure =
        cards.firstWhere((c) => c.kind == TendencyKind.underPressure);
    expect(pressure.figures, isNull);
    expect(pressure.confidence, TendencyConfidence.early);
    expect(pressure.unlockAction, 'Answer practice questions');
    final speed = cards.firstWhere((c) => c.kind == TendencyKind.howYouAnswer);
    expect(
      speed.unlockAction,
      'Answer timed questions correctly and incorrectly',
    );
  });

  for (final (removeReads, removeAnswers, action) in [
    (true, false, 'Read a lesson in a topic you have practiced'),
    (false, true, 'Answer questions in a topic you have read'),
    (true, true, 'Read a lesson and answer questions in its topic'),
  ]) {
    test('study unlock names the missing data: $action', () async {
      await seedInitialData(db, contentDb);
      if (removeReads) await db.delete(db.lessonProgressLocal).go();
      if (removeAnswers) await db.delete(db.attemptsLocal).go();
      final cards = await container.read(tendenciesProvider.future);
      final study = cards.firstWhere((c) => c.kind == TendencyKind.howYouStudy);
      expect(study.figures, isNull);
      expect(study.unlockAction, action);
    });
  }

  for (final (readCount, answeredCount, confidence) in [
    (1, 1, TendencyConfidence.early),
    (5, 5, TendencyConfidence.forming),
    (9, 1, TendencyConfidence.clear),
  ]) {
    test('study carries $confidence for Free and Pro before 14 sessions',
        () async {
      await seedInitialData(
        db,
        contentDb,
        readThenQuiz: readCount,
        quizFirst: answeredCount,
      );
      await db.delete(db.quizSessions).go();
      for (final entitlement in [
        const Entitlement.free(),
        const Entitlement(plan: EntitlementPlan.monthly),
      ]) {
        final c = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            entitlementProvider
                .overrideWith((ref) => Stream.value(entitlement)),
          ],
        );
        final cards = await c.read(tendenciesProvider.future);
        final study =
            cards.firstWhere((c) => c.kind == TendencyKind.howYouStudy);
        expect(study.figures, (left: '$readCount', right: '$answeredCount'));
        expect(study.confidence, confidence);
        expect(
          study.sentence,
          confidence == TendencyConfidence.clear
              ? 'You usually read the lesson first.'
              : null,
        );
        c.dispose();
      }
    });
  }

  for (final (practice, first, second, timed, confidence) in [
    (0.98, 0.96, 0.96, true, TendencyConfidence.early),
    (0.68, 0.8, 0.76, false, TendencyConfidence.forming),
    (0.6, 0.6, 0.2, true, TendencyConfidence.clear),
  ]) {
    test('pressure, stamina, and speed return $confidence with early figures',
        () async {
      await seedInitialData(
        db,
        contentDb,
        practiceAcc: practice,
        firstHalfAcc: first,
        secondHalfAcc: second,
        includeSpeed: timed,
      );
      await db.delete(db.quizSessions).go();
      final cards = await container.read(tendenciesProvider.future);
      for (final kind in [
        TendencyKind.underPressure,
        TendencyKind.stamina,
        TendencyKind.howYouAnswer,
      ]) {
        final card = cards.firstWhere((c) => c.kind == kind);
        expect(card.figures, isNotNull);
        expect(card.confidence, confidence, reason: kind.name);
        expect(card.sentence != null, confidence == TendencyConfidence.clear);
      }
    });
  }

  test('constant 1s correct and 2s wrong times withhold the claim', () async {
    await seedInitialData(db, contentDb);
    await _writeTimes(db, List.filled(30, 1000), List.filled(30, 2000));
    final work = await container.read(tendenciesProvider.future);
    final speed = work.firstWhere((t) => t.kind == TendencyKind.howYouAnswer);
    expect(speed.confidence, TendencyConfidence.forming);
    expect(speed.sentence, isNull);
  });

  for (final outlier in [61000, 121000]) {
    for (final varied in [false, true]) {
      test(
          'log-time figures and direction with $outlier outlier, '
          'varied: $varied', () async {
        await seedInitialData(db, contentDb);
        // Exact review scenarios: 60 correct at 2s, 59 wrong at 1s,
        // one wrong at 61s or 121s. Arithmetic means tie or reverse.
        // Geometric means: correct 2s, wrong 61^(1/60)=1.071s or
        // 121^(1/60)=1.083s. Varied correct times permit Welch testing.
        await _writeTimes(
          db,
          List.generate(60, (i) => varied ? (i.isEven ? 1999 : 2001) : 2000),
          [...List.filled(59, 1000), outlier],
        );
        final work = await container.read(tendenciesProvider.future);
        final speed =
            work.firstWhere((t) => t.kind == TendencyKind.howYouAnswer);
        expect(speed.figures, (left: '2s', right: '1s'));
        expect(
          speed.confidence,
          varied ? TendencyConfidence.clear : TendencyConfidence.forming,
        );
        expect(
          speed.sentence,
          varied ? 'You answer 1s faster on questions you get wrong.' : null,
        );
      });
    }
  }

  for (final rises in [false, true]) {
    test('clear 3995/4000 vs 3985/4000 keeps direction, rises: $rises',
        () async {
      await seedInitialData(db, contentDb);
      // Pooled p=.9975, z=2.2388683, p=.02516361. Both figures
      // round to 100%, but the actual gap is .25 percentage points.
      final a = rises ? 3985 : 3995;
      final b = rises ? 3995 : 3985;
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          metricsSignalProvider.overrideWith((ref, request) async {
            final Object value;
            if (request.signal == SignalKey.testModeDelta) {
              value = PressureDelta(
                practiceAccuracy: a / 4000,
                mockAccuracy: b / 4000,
                practiceCorrect: a,
                practiceTotal: 4000,
                mockCorrect: b,
                mockTotal: 4000,
              );
            } else if (request.signal == SignalKey.mockStamina) {
              value = StaminaDelta(
                firstHalfAccuracy: a / 4000,
                secondHalfAccuracy: b / 4000,
                firstHalfCorrect: a,
                firstHalfTotal: 4000,
                secondHalfCorrect: b,
                secondHalfTotal: 4000,
              );
            } else {
              return null;
            }
            return SignalResult<Object>(
              window: ResolvedMetricsWindow(
                window: request.window,
                start: null,
                end: request.now,
                sessionCount: 1,
                minSessionCount: 1,
              ),
              value: value,
            );
          }),
        ],
      );
      addTearDown(c.dispose);
      final work = await c.read(tendenciesProvider.future);
      final pressure =
          work.firstWhere((t) => t.kind == TendencyKind.underPressure);
      final stamina = work.firstWhere((t) => t.kind == TendencyKind.stamina);
      expect(pressure.figures, (left: '100%', right: '100%'));
      expect(pressure.confidence, TendencyConfidence.clear);
      expect(stamina.confidence, TendencyConfidence.clear);
      expect(
        pressure.sentence,
        rises
            ? 'Accuracy rises 0.3% under exam pressure.'
            : 'Accuracy drops 0.3% under exam pressure.',
      );
      expect(
        stamina.sentence,
        rises
            ? 'Accuracy rises 0.3% in the second half of a mock.'
            : 'Accuracy drops 0.3% in the second half of a mock.',
      );
    });
  }

  for (final slower in [false, true]) {
    test('clear subsecond speed gap keeps direction, slower: $slower',
        () async {
      await seedInitialData(db, contentDb);
      // Each group varies by 2ms; geometric means are about 1.001s
      // and 1.401s, with a clear .4s gap despite both rounding to 1s.
      final fast = List.generate(60, (i) => i.isEven ? 1000 : 1002);
      final slow = List.generate(60, (i) => i.isEven ? 1400 : 1402);
      await _writeTimes(db, slower ? fast : slow, slower ? slow : fast);
      final work = await container.read(tendenciesProvider.future);
      final speed = work.firstWhere((t) => t.kind == TendencyKind.howYouAnswer);
      expect(speed.figures, (left: '1s', right: '1s'));
      expect(speed.confidence, TendencyConfidence.clear);
      expect(
        speed.sentence,
        slower
            ? 'You spend 0.4s longer on questions you get wrong.'
            : 'You answer 0.4s faster on questions you get wrong.',
      );
    });
  }

  test('unlock lines state the whole condition', () async {
    await seedInitialData(db, contentDb, includeMock: false);
    final cards = await container.read(tendenciesProvider.future);
    final expected = {
      TendencyKind.underPressure: 'Finish one full length mock',
      TendencyKind.stamina: 'Finish one full length mock',
      TendencyKind.howYouStudy: 'Read a lesson in a topic you have practiced',
      TendencyKind.howYouAnswer: 'Answer timed questions incorrectly',
    };
    for (final card in cards) {
      expect(card.unlockAction, expected[card.kind]);
    }
  });

  test('fixed order separates data and empty cards for every subset', () async {
    await seedInitialData(db, contentDb);
    const order = [
      TendencyKind.underPressure,
      TendencyKind.stamina,
      TendencyKind.howYouAnswer,
      TendencyKind.howYouStudy,
    ];
    const keys = [
      SignalKey.testModeDelta,
      SignalKey.mockStamina,
      SignalKey.perQuestionSpeed,
      SignalKey.readThenQuiz,
    ];
    const values = <Object>[
      PressureDelta(
        practiceAccuracy: 0.8,
        mockAccuracy: 0.7,
        practiceCorrect: 8,
        practiceTotal: 10,
        mockCorrect: 7,
        mockTotal: 10,
      ),
      StaminaDelta(firstHalfAccuracy: 0.4, secondHalfAccuracy: 0.9),
      LatencyDistribution(
        averageMs: 35000,
        correctAverageMs: 10000,
        incorrectAverageMs: 60000,
        sampleCount: 20,
        correctCount: 10,
        incorrectCount: 10,
      ),
      WorkflowRatio(readThenQuizCount: 4, quizFirstCount: 2),
    ];
    for (var mask = 0; mask < 16; mask++) {
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          metricsSignalProvider.overrideWith((ref, request) async {
            final i = keys.indexOf(request.signal);
            if (i < 0 || mask & (1 << i) == 0) return null;
            return SignalResult<Object>(
              window: ResolvedMetricsWindow(
                window: request.window,
                start: null,
                end: request.now,
                sessionCount: 14,
                minSessionCount: 14,
              ),
              value: values[i],
            );
          }),
        ],
      );
      final cards = await c.read(tendenciesProvider.future);
      expect(
        cards.map((card) => card.kind),
        [
          for (var i = 0; i < 4; i++)
            if (mask & (1 << i) != 0) order[i],
          for (var i = 0; i < 4; i++)
            if (mask & (1 << i) == 0) order[i],
        ],
        reason: 'data subset $mask',
      );
      c.dispose();
    }
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('always four cards, in every data state', () async {
    await seedInitialData(db, contentDb);
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
    await seedInitialData(db, contentDb, includeMock: false);
    final cards = await container.read(tendenciesProvider.future);
    final stamina = cards.firstWhere((c) => c.kind == TendencyKind.stamina);

    expect(stamina.figures, isNull);
    expect(stamina.sentence, isNull);
    expect(stamina.leftLabel, isNotEmpty, reason: 'labels always show');
    expect(stamina.rightLabel, isNotEmpty);
    expect(
      stamina.unlockAction,
      'Finish one full length mock',
    );
  });

  test('measurable cards sort before blocked ones', () async {
    // Only howYouAnswer has data (speed dist data).
    final customDb = inMemoryDatabase();
    final customContentDb = openTestContentDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(customContentDb),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      customContentDb,
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

  test('pressure comes first among measurable cards', () async {
    // pressure delta -0.18, stamina delta -0.04.
    final customDb = inMemoryDatabase();
    final customContentDb = openTestContentDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(customContentDb),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      customContentDb,
      mockAcc: 0.50, // pressure delta -0.18
    );

    final cards = await customContainer.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.underPressure);

    customContainer.dispose();
    await customDb.close();
  });

  test('fixed order does not depend on the size or sign of a gap', () async {
    // stamina delta +0.20, pressure delta -0.05.
    final customDb = inMemoryDatabase();
    final customContentDb = openTestContentDatabase();
    final customContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(customDb),
        contentDatabaseProvider.overrideWithValue(customContentDb),
      ],
    );
    await customContainer
        .read(appPreferencesRepositoryProvider)
        .setSelectedExamId('exam_upcat');
    await seedInitialData(
      customDb,
      customContentDb,
      mockAcc: 0.63, // pressure delta -0.05
      firstHalfAcc: 0.60,
      secondHalfAcc: 0.80, // stamina delta +0.20
    );

    final cards = await customContainer.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.underPressure);

    customContainer.dispose();
    await customDb.close();
  });

  test('no user-facing string names the scheduler', () async {
    await seedInitialData(db, contentDb);
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

Future<void> _writeTimes(
  AppDatabase db,
  List<int> correct,
  List<int> wrong,
) async {
  final items = <Map<String, Object>>[
    for (var i = 0; i < correct.length + wrong.length; i++)
      {
        'questionId': 'q_$i',
        'questionVersion': 1,
        'chosenChoiceId': i < correct.length ? 'a' : 'b',
        'correctChoiceId': 'a',
        'responseMs':
            i < correct.length ? correct[i] : wrong[i - correct.length],
      },
  ];
  await (db.update(db.attemptsLocal)
        ..where((row) => row.id.equals('att_practice')))
      .write(AttemptsLocalCompanion(itemsJson: Value(jsonEncode(items))));
}
