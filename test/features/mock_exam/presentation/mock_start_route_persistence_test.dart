import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';

import '../../../helpers/in_memory_database.dart';

class _ErrorSink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

void main() {
  testWidgets('fresh native failure hides diagnostics and retries the load',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    final error = StateError('private question pool diagnostic');
    final sink = _ErrorSink();
    var fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          telemetryProvider.overrideWithValue(sink),
          mockQuestionPoolsProvider('exam_cse').overrideWith((ref) async {
            if (fail) throw error;
            return const MockQuestionPools(
              poolsByTopic: {
                'topic_1': ['q1', 'q2'],
              },
              passageSetsByTopic: {},
            );
          }),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('private question pool diagnostic'),
      findsNothing,
    );
    expect(find.text('Could not load your mock.'), findsOneWidget);
    expect(sink.errors, contains(same(error)));
    fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Start the Paper'), findsOneWidget);
    expect(find.text('Could not load your mock.'), findsNothing);
  });

  testWidgets('submission retries scoring questions after a load failure',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    final sink = _ErrorSink();
    var loads = 0;
    var fail = true;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
        GoRoute(
          path: '/mock/results/:attemptId',
          builder: (context, state) => const Scaffold(body: Text('Results')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          telemetryProvider.overrideWithValue(sink),
          mockScoringQuestionsProvider.overrideWith((ref, id) async {
            loads++;
            if (fail) throw StateError('private scoring diagnostic');
            return ref
                .read(contentRepositoryProvider)
                .questionsByIds({'q1', 'q2'});
          }),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);
    await tester.tap(find.text('Choice A'));
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text('Could not load your mock.'), findsOneWidget);
    expect(find.textContaining('private scoring diagnostic'), findsNothing);
    expect(sink.errors, hasLength(1));
    expect(
      (await db.select(db.mockAttempts).get()).single.status,
      'in_progress',
    );

    fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text('Results'), findsOneWidget);
    final attempt = (await db.select(db.mockAttempts).get()).single;
    expect(attempt.status, 'completed');
    expect(attempt.scoreRaw, 1);
    expect(attempt.scoreTotal, 2);
  });

  testWidgets('backgrounding persists the latest mock answer and position',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    await tester.tap(find.text('Choice A'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await tester.pump();

    final attempt = (await db.select(db.mockAttempts).get()).single;
    final answers = jsonDecode(attempt.answersJson) as Map<String, Object?>;
    expect(answers, hasLength(1));
    expect(answers.values.single, {'selectedIndex': 0, 'atSec': 0});
    expect(attempt.currentIndex, 1);

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
  });

  testWidgets('restart restores the same mock answer position and clock',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
    const codec = MockSessionSnapshotCodec();
    const sample = MockSample(
      expectedQuestionCount: 2,
      sections: [
        SampledMockSection(
          sectionId: 'section_1',
          name: 'Part 1',
          questionIds: ['q1', 'q2'],
        ),
      ],
    );
    final now = DateTime.now();
    final repo = MockAttemptRepo(db);
    await repo.insertStart(
      MockAttemptStart(
        id: 'mock_1',
        userId: mockAttemptLocalUserId,
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 30,
        strictMode: false,
        sampledQuestionsJson: codec.encodeSample(
          sample,
          currentPartIndex: 0,
          partStartedAtSeconds: 0,
          partsTimedSeparately: false,
          parts: const [
            MockPersistedPart(
              name: '',
              startIndex: 0,
              count: 2,
              minutes: null,
            ),
          ],
        ),
        startedAt: now,
      ),
    );
    await repo.flushProgress(
      attemptId: 'mock_1',
      elapsedSeconds: 45,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: true,
      answersJson: codec.encodeAnswers(const {
        'q1': MockAnswer(selectedIndex: 0, atSec: 20),
      }),
      flagsJson: codec.encodeFlags(const {'q2'}),
      currentIndex: 1,
      flushedAt: now,
    );
    await contentDb.delete(contentDb.contentMockBlueprints).go();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute.resume(resumeAttemptId: 'mock_1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    expect(find.text('2 of 2'), findsOneWidget);
    expect(
      tester.widget<QuestionCard>(find.byType(QuestionCard)).stem,
      'Question q2?',
    );
    await tester.tap(find.byKey(const ValueKey('mock-prev')));
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);
    final firstQuestion =
        tester.widget<QuestionCard>(find.byType(QuestionCard));
    expect(firstQuestion.stem, 'Question q1?');
    expect(
      tester.widget<ChoiceRow>(find.byType(ChoiceRow).first).state,
      ChoiceRowState.picked,
    );
    expect(find.text('29:15'), findsOneWidget);
    expect(await db.select(db.mockAttempts).get(), hasLength(1));
  });

  testWidgets('timed part expiry persists a stopped transition',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
    const codec = MockSessionSnapshotCodec();
    const sample = MockSample(
      expectedQuestionCount: 2,
      sections: [
        SampledMockSection(
          sectionId: 'section_1',
          name: 'Part 1',
          questionIds: ['q1'],
        ),
        SampledMockSection(
          sectionId: 'section_2',
          name: 'Part 2',
          questionIds: ['q2'],
        ),
      ],
    );
    const parts = [
      MockPersistedPart(
        name: 'Part 1',
        startIndex: 0,
        count: 1,
        minutes: 1,
      ),
      MockPersistedPart(
        name: 'Part 2',
        startIndex: 1,
        count: 1,
        minutes: 1,
      ),
    ];
    final now = DateTime.now();
    final repo = MockAttemptRepo(db);
    await repo.insertStart(
      MockAttemptStart(
        id: 'mock_sectional',
        userId: mockAttemptLocalUserId,
        examId: 'exam_cse',
        blueprintId: 'retired_blueprint',
        blueprintName: 'Frozen Practice',
        durationMinutes: 2,
        strictMode: false,
        sampledQuestionsJson: codec.encodeSample(
          sample,
          currentPartIndex: 0,
          partStartedAtSeconds: 0,
          partsTimedSeparately: true,
          parts: parts,
        ),
        startedAt: now,
      ),
    );
    await repo.flushProgress(
      attemptId: 'mock_sectional',
      elapsedSeconds: 59,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: true,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      flushedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute.resume(
            resumeAttemptId: 'mock_sectional',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);
    expect(
      tester.widget<QuestionCard>(find.byType(QuestionCard)).stem,
      'Question q1?',
    );

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byType(PartTransitionPage), findsOneWidget);
    expect(find.text('Question q2?'), findsNothing);
    final attempt = await repo.findById('mock_sectional');
    final restored = codec.decode(
      sampledQuestionsJson: attempt!.sampledQuestionsJson,
      answersJson: attempt.answersJson,
      flagsJson: attempt.flagsJson,
    );
    expect(restored.currentPartIndex, 1);
    expect(restored.betweenParts, isTrue);
    expect(restored.partStartedAtSeconds, 60);
    expect(attempt.currentIndex, 1);
  });

  testWidgets('strict restart after the background limit forfeits and scores',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
    const codec = MockSessionSnapshotCodec();
    const sample = MockSample(
      expectedQuestionCount: 2,
      sections: [
        SampledMockSection(
          sectionId: 'section_1',
          name: 'Part 1',
          questionIds: ['q1', 'q2'],
        ),
      ],
    );
    const parts = [
      MockPersistedPart(
        name: '',
        startIndex: 0,
        count: 2,
        minutes: null,
      ),
    ];
    final now = DateTime.now();
    final repo = MockAttemptRepo(db);
    await repo.insertStart(
      MockAttemptStart(
        id: 'mock_strict',
        userId: mockAttemptLocalUserId,
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 1,
        strictMode: true,
        sampledQuestionsJson: codec.encodeSample(
          sample,
          currentPartIndex: 0,
          partStartedAtSeconds: 0,
          partsTimedSeparately: false,
          parts: parts,
          strictBackgroundedAt: now.subtract(const Duration(seconds: 60)),
        ),
        startedAt: now.subtract(const Duration(seconds: 70)),
      ),
    );
    await repo.flushProgress(
      attemptId: 'mock_strict',
      elapsedSeconds: 4,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: codec.encodeAnswers(const {
        'q1': MockAnswer(selectedIndex: 0, atSec: 2),
      }),
      flagsJson: '[]',
      currentIndex: 1,
      flushedAt: now.subtract(const Duration(seconds: 60)),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MockStartRoute.resume(
            resumeAttemptId: 'mock_strict',
          ),
        ),
        GoRoute(
          path: '/mock/results/:attemptId',
          builder: (context, state) => const Scaffold(body: Text('Results')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    expect(find.text('Results'), findsOneWidget);
    final attempt = await repo.findById('mock_strict');
    expect(attempt!.status, MockAttemptStatus.forfeited);
    expect(attempt.scoreRaw, 1);
    expect(attempt.scoreTotal, 2);
  });

  testWidgets('corrupt saved state can be discarded', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
    const codec = MockSessionSnapshotCodec();
    const sample = MockSample(
      expectedQuestionCount: 2,
      sections: [
        SampledMockSection(
          sectionId: 'section_1',
          name: 'Part 1',
          questionIds: ['q1', 'q2'],
        ),
      ],
    );
    final now = DateTime.now();
    final repo = MockAttemptRepo(db);
    await repo.insertStart(
      MockAttemptStart(
        id: 'mock_corrupt',
        userId: mockAttemptLocalUserId,
        examId: 'exam_cse',
        blueprintId: 'bp_cse',
        blueprintName: 'CSE Practice',
        durationMinutes: 30,
        strictMode: false,
        sampledQuestionsJson: codec.encodeSample(
          sample,
          currentPartIndex: 9,
          partStartedAtSeconds: 0,
          partsTimedSeparately: false,
          parts: const [
            MockPersistedPart(
              name: '',
              startIndex: 0,
              count: 2,
              minutes: null,
            ),
          ],
        ),
        startedAt: now,
      ),
    );
    final router = GoRouter(
      initialLocation: '/mock',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/mock',
          builder: (context, state) => const MockStartRoute.resume(
            resumeAttemptId: 'mock_corrupt',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    expect(find.text('Could not load your mock.'), findsOneWidget);
    expect(find.textContaining('FormatException'), findsNothing);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Discard saved mock'));
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(
      (await repo.findById('mock_corrupt'))!.status,
      MockAttemptStatus.discarded,
    );
  });

  testWidgets('scheduler debounces a live answer into the database',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    await tester.tap(find.text('Choice A'));
    for (var tick = 0; tick < 4; tick += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 99));
    var attempt = (await db.select(db.mockAttempts).get()).single;
    expect(attempt.answersJson, '{}');

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    attempt = (await db.select(db.mockAttempts).get()).single;
    expect(jsonDecode(attempt.answersJson), hasLength(1));
  });

  testWidgets('scheduler heartbeat persists the live clock', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    for (var second = 0; second < 30; second += 1) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump();

    final attempt = (await db.select(db.mockAttempts).get()).single;
    expect(attempt.lastFlushedAt.isAfter(attempt.startedAt), isTrue);
  });

  testWidgets('system back pauses and saves the paused paper', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    await tester.tap(find.text('Choice A'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    // The paused screen's hourglass tips for as long as it is open, so the
    // frame never settles.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PausePage), findsOneWidget);
    final attempt = (await db.select(db.mockAttempts).get()).single;
    expect(attempt.pausedAtLastFlush, isTrue);
    expect(jsonDecode(attempt.answersJson), hasLength(1));
  });

  testWidgets('a student who chose not to see the warning pauses at once',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
    await AppPreferencesRepository(db)
        .setDeviceValue('mock_pause_warning_seen', 'true');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    await tester.tap(find.byKey(const ValueKey('mock-pause')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text("Real exams don't pause."), findsNothing);
    expect(find.byType(PausePage), findsOneWidget);
  });

  testWidgets('leaving the app pauses a paper that is not strict',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final contentDb = openTestContentDatabase();
    await _seedMockContent(contentDb);
    await AppPreferencesRepository(db).setSelectedExamId('exam_cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MockStartRoute(
            examId: 'exam_cse',
            blueprintId: 'bp_cse',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startPreparedPaperIfPresent(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    final saved = (await db.select(db.mockAttempts).get()).single;
    expect(saved.pausedAtLastFlush, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PausePage), findsOneWidget);
  });
}

Future<void> _startPreparedPaperIfPresent(WidgetTester tester) async {
  final start = find.text('Start the Paper');
  if (start.evaluate().isEmpty) return;
  await tester.tap(start);
  await tester.pumpAndSettle();
}

Future<void> _seedMockContent(ContentDatabase db) async {
  await seedContentExam(
    db,
    examId: 'exam_cse',
    code: 'CSE',
    name: 'Civil Service Exam',
    shortName: 'CSE',
  );
  await seedContentSubject(
    db,
    subjectId: 'subject_1',
    examId: 'exam_cse',
  );
  await seedContentTopic(
    db,
    topicId: 'topic_1',
    subjectId: 'subject_1',
  );
  await seedContentQuestion(
    db,
    questionId: 'q1',
    topicId: 'topic_1',
    examId: 'exam_cse',
  );
  await seedContentQuestion(
    db,
    questionId: 'q2',
    topicId: 'topic_1',
    examId: 'exam_cse',
  );
  await db.into(db.contentMockBlueprints).insert(
        ContentMockBlueprintsCompanion.insert(
          id: 'bp_cse',
          schemaVersion: 1,
          updatedAt: DateTime.utc(2026, 9, 4),
          examId: 'exam_cse',
          name: 'CSE Practice',
          durationMinutes: 30,
          sectionsJson: jsonEncode([
            {
              'id': 'section_1',
              'name': 'Part 1',
              'questionCount': 2,
              'suggestedMinutes': 30,
              'topicIds': ['topic_1'],
            },
          ]),
          sectionalTiming: const Value('roamable'),
        ),
      );
}
