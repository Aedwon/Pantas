import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/application/assessment_result_providers.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
      initialLocation: '/assessment/$examId',
      routes: [
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

Future<AppDatabase> _seedDb() async {
  final db = inMemoryDatabase();
  await db.into(db.exams).insert(
        ExamsCompanion.insert(
          id: 'e1',
          code: 'CSE',
          name: 'CSE',
          shortName: 'CSE',
          language: 'en',
        ),
      );
  await db.into(db.subjects).insert(
        SubjectsCompanion.insert(
          id: 's1',
          examId: 'e1',
          name: 'Verbal',
          ordering: 1,
        ),
      );
  await db.into(db.topics).insert(
        TopicsCompanion.insert(
          id: 't1',
          subjectId: 's1',
          name: 'Vocabulary',
          ordering: 1,
        ),
      );
  final choices = jsonEncode([
    {'id': 'c_a', 'label': 'A', 'text': 'Option A', 'isCorrect': true},
    {'id': 'c_b', 'label': 'B', 'text': 'Option B', 'isCorrect': false},
  ]);
  await db.into(db.questions).insert(
        QuestionsCompanion.insert(
          id: 'q1',
          version: 1,
          examIdsJson: jsonEncode(['e1']),
          topicId: 't1',
          language: 'en',
          stem: 'What does ephemeral mean?',
          choicesJson: choices,
          explanation: 'Short-lived.',
        ),
      );
  return db;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = await _seedDb();
  });

  tearDown(() => db.close());

  testWidgets('shows progress bar when assessment is running', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 1'), findsOneWidget);
  });

  testWidgets('answering last question navigates to results page',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('completing refreshes a result already cached as absent',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
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

    expect(
      await container.read(assessmentResultProvider('e1').future),
      isNotNull,
      reason: 'the results page reads this provider — a stale null renders '
          '"No assessment found." after a completed run',
    );
  });

  testWidgets('redirects to results when assessment is already completed',
      (tester) async {
    await AssessmentRepository(db).saveResult(
      'e1',
      DateTime.utc(2026, 5, 11),
      [const TopicScore(topicId: 't1', correct: 1, total: 1)],
    );

    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Question 1 of 1'), findsNothing);
  });

  testWidgets('back navigation shows confirm dialog', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    await navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Leave assessment?'), findsOneWidget);
  });
}
