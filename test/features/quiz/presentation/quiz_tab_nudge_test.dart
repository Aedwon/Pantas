import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const QuizTabHome()),
        GoRoute(
          path: '/quiz/today/:examId',
          builder: (_, state) =>
              Text('Today ${state.pathParameters['examId']}'),
        ),
        GoRoute(
          path: '/quiz/drill/:examId',
          builder: (_, __) => const Text('Drill'),
        ),
        GoRoute(
          path: '/quiz/retake/:examId',
          builder: (_, __) => const Text('Retake'),
        ),
        GoRoute(path: '/study', builder: (_, __) => const Text('Study')),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const Text('Onboarding'),
        ),
      ],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e2',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
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
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Lesson 1',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
    await AppPreferencesRepository(db).setSelectedExamId('e1');
  });

  tearDown(() => db.close());

  testWidgets('shows nudge bottom sheet on first quiz tap with no lessons read',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Start Today's Session"));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsOneWidget);
  });

  testWidgets('shows only selected exam quiz entry', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Civil Service Exam'), findsOneWidget);
    expect(find.text('UPCAT'), findsNothing);
  });

  testWidgets('start today session uses selected exam id', (tester) async {
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Start Today's Session"));
    await tester.pumpAndSettle();

    expect(find.text('Today e1'), findsOneWidget);
  });

  testWidgets('renders Retake and Drill practice CTAs', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Retake Mistakes'), findsOneWidget);
    expect(find.text('Drill a topic'), findsOneWidget);
  });

  testWidgets('does not show nudge when nudge already dismissed',
      (tester) async {
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Start Today's Session"));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });

  testWidgets('does not show nudge when at least one lesson is read',
      (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Start Today's Session"));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });

  testWidgets('missing selected focus shows choose exam fallback',
      (tester) async {
    await AppPreferencesRepository(db).setSelectedExamId('removed');

    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your exam'), findsOneWidget);
    await tester.tap(find.text('Choose exam'));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });
}
