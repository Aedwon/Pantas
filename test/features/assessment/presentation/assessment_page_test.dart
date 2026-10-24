import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/presentation/assessment_page.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
      initialLocation: '/assessment/$examId',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, state) =>
              AssessmentPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, __) => const Scaffold(body: Text('Results')),
        ),
      ],
    );

Future<ContentDatabase> _seedContentDb() async {
  final db = inMemoryContentDatabase();
  await seedContentExam(db, examId: 'e1', code: 'CSE', name: 'CSE');
  await seedContentSubject(db, subjectId: 's1', examId: 'e1', name: 'Verbal');
  await seedContentTopic(
    db,
    topicId: 't1',
    subjectId: 's1',
    name: 'Vocabulary',
  );
  await seedContentQuestion(
    db,
    questionId: 'q1',
    topicId: 't1',
    examId: 'e1',
    stem: 'What does ephemeral mean?',
    correctText: 'Option A',
    wrongText: 'Option B',
  );
  return db;
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = await _seedContentDb();
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  List<Override> databaseOverrides() => [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ];

  testWidgets('shows progress bar when assessment is running', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 1'), findsOneWidget);
    expect(find.text('Answers show at the end.'), findsOneWidget);
  });

  testWidgets('answering last question navigates to results page',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('completing refreshes a result already cached as absent',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // The Home tab watches this provider from inside the bottom-nav shell, so
    // by the time the user starts an assessment it is already cached as null.
    // It is not autoDispose and the shell never unmounts, so nothing evicts it.
    expect(await container.read(assessmentResultProvider('e1').future), isNull);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      await container.read(assessmentResultProvider('e1').future),
      isNotNull,
      reason: 'the results page reads this provider — a stale null renders '
          '"No assessment found." after a completed run',
    );
  });

  testWidgets('completing assessment publishes Quiz session refresh',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final before = container.read(quizSessionPanelRevisionProvider);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(
      container.read(quizSessionPanelRevisionProvider),
      before + 1,
    );
  });

  testWidgets('completed assessment opens Home without retake', (tester) async {
    await AssessmentRepository(db).saveResult(
      'e1',
      DateTime.utc(2026, 5, 11),
      [const TopicScore(topicId: 't1', correct: 1, total: 1)],
    );

    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('1 of 1'), findsNothing);
  });

  testWidgets('zero-content exam shows an intentional unavailable state',
      (tester) async {
    await seedContentExam(
      contentDb,
      examId: 'empty',
      code: 'ACET',
      name: 'ACET',
      ordering: 2,
    );

    await tester.pumpAppWithRouter(
      _buildRouter('empty'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text("Assessment isn't ready yet"), findsOneWidget);
    expect(find.textContaining('Bad state:'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('back navigation shows confirm dialog', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    await navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Leave assessment?'), findsOneWidget);
  });
  testWidgets('changed sync owner discards the old picks without writing',
      (tester) async {
    final contexts = SyncActiveContextStore(db);
    await contexts.publishStable(uid: 'original', generationId: 'g1');
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    await contexts.publishStable(uid: 'new-owner', generationId: 'g2');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(await AssessmentRepository(db).hasCompletedForExam('e1'), isFalse);
    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Option A'), findsNothing);
  });
}
