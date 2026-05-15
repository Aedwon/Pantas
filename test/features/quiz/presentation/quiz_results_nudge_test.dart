import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String attemptId) => GoRouter(
      initialLocation: '/quiz/results/$attemptId',
      routes: [
        GoRoute(
          path: '/quiz/results/:attemptId',
          builder: (_, state) =>
              QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
        ),
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, __) => const Scaffold(body: Text('Assessment')),
        ),
      ],
    );

// Seeds `count` attempts for exam 'e1', plus a specific attempt with the given id.
Future<void> _seedAttempts(
  AppDatabase db, {
  required String id,
  required int count,
}) async {
  final now = DateTime(2026, 1, 1);
  for (var i = 0; i < count; i++) {
    await db.into(db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: '${id}_bg_$i',
            examId: 'e1',
            startedAt: now,
            completedAt: Value(now),
            itemsJson: jsonEncode([]),
          ),
        );
  }
  // The result page loads by this specific attemptId
  await db.into(db.attemptsLocal).insertOnConflictUpdate(
        AttemptsLocalCompanion.insert(
          id: id,
          examId: 'e1',
          startedAt: now,
          completedAt: Value(now),
          itemsJson: jsonEncode([]),
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  testWidgets(
      'shows bottom sheet nudge after first attempt with no assessment',
      (tester) async {
    await _seedAttempts(db, id: 'a1', count: 1);

    await tester.pumpAppWithRouter(
      _buildRouter('a1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Get your personalized study plan'),
      findsOneWidget,
    );
  });

  testWidgets('does not show nudge when assessment already completed',
      (tester) async {
    await _seedAttempts(db, id: 'a1', count: 1);
    await AssessmentRepository(db)
        .saveResult('e1', DateTime(2026, 1, 1), []);

    await tester.pumpAppWithRouter(
      _buildRouter('a1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Get your personalized study plan'),
      findsNothing,
    );
  });

  testWidgets('shows bottom sheet nudge after third attempt', (tester) async {
    await _seedAttempts(db, id: 'a3', count: 3);

    await tester.pumpAppWithRouter(
      _buildRouter('a3'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("You've done 3 quizzes"), findsOneWidget);
  });

  testWidgets('shows persistent banner after 5+ attempts', (tester) async {
    await _seedAttempts(db, id: 'a5', count: 5);

    await tester.pumpAppWithRouter(
      _buildRouter('a5'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Your study plan is waiting. Take the assessment →'),
      findsOneWidget,
    );
  });
}
