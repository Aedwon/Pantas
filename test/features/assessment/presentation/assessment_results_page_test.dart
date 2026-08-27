import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
      initialLocation: '/assessment/$examId/results',
      routes: [
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, state) =>
              AssessmentResultsPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/study',
          builder: (_, __) => const Scaffold(body: Text('Lessons')),
        ),
        GoRoute(
          path: '/quiz/quick/:examId',
          builder: (_, state) => Scaffold(
            body: Text('Quiz ${state.uri.queryParameters['topicId']}'),
          ),
        ),
      ],
    );

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Verbal',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's1',
      name: 'Reading Comprehension',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 't3',
      subjectId: 's1',
      name: 'Using context clues in unusually long reading passages',
      ordering: 3,
    );

    // t1: weak, t3: moderate, t2: strong.
    await AssessmentRepository(db).saveResult('e1', DateTime(2026), [
      const TopicScore(topicId: 't1', correct: 0, total: 3),
      const TopicScore(topicId: 't2', correct: 3, total: 3),
      const TopicScore(topicId: 't3', correct: 1, total: 2),
    ]);
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  List<Override> databaseOverrides() => [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ];

  testWidgets('shows topic bars sorted weakest-first', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary'), findsWidgets);
    expect(find.text('Reading Comprehension'), findsWidgets);

    final vocabY = tester.getTopLeft(find.text('Vocabulary').first).dy;
    final readingY =
        tester.getTopLeft(find.text('Reading Comprehension').first).dy;
    expect(vocabY, lessThan(readingY));
  });

  testWidgets('shows exam-specific profile header', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Civil Service Exam profile'), findsOneWidget);
  });

  testWidgets('weak topic shows Start here badge', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start here'), findsOneWidget);
  });

  testWidgets('focus row opens lessons using study route', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start here'));
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
  });

  testWidgets('Start studying opens the weakest topic lessons', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start studying'));
    await tester.tap(find.text('Start studying'));
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
  });

  testWidgets('each mastery color has an equivalent semantic label',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: databaseOverrides(),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Vocabulary, 0%, Weak'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Using context clues in unusually long reading passages, 50%, '
        'Moderate',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Reading Comprehension, 100%, Strong'),
      findsOneWidget,
    );
  });

  testWidgets('topic rows survive 200% text at 320dp', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: databaseOverrides(),
        child: MaterialApp.router(
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          routerConfig: _buildRouter('e1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
