import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_home.dart';

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
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentExam(
      contentDb,
      examId: 'e2',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
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
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Lesson 1',
      bodyJson: jsonEncode([]),
    );
    // The session panel offers a session only when there are questions to
    // build one from. Without these it sits in its assessment state and the
    // nudge never gets a chance to fire.
    for (var i = 1; i <= 12; i++) {
      await seedContentQuestionWithChoices(
        contentDb,
        questionId: 'q$i',
        topicId: 't1',
        examId: 'e1',
        choices: const [],
        stem: 'Question $i',
        explanation: 'Because.',
      );
    }
    // The panel leads with the assessment until one is completed, so without
    // this the nudge never gets a chance to fire.
    await db.into(db.assessmentResultsLocal).insert(
          AssessmentResultsLocalCompanion.insert(
            examId: 'e1',
            completedAt: DateTime.now(),
            topicScoresJson: '{}',
          ),
        );
    await AppPreferencesRepository(db).setSelectedExamId('e1');
  });

  tearDown(() => db.close());

  testWidgets('shows nudge bottom sheet on first quiz tap with no lessons read',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsOneWidget);
  });

  testWidgets('shows only selected exam quiz entry', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('CSE'), findsOneWidget);
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Today e1'), findsOneWidget);
  });

  testWidgets('renders practice CTAs', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Your mistakes'), findsOneWidget);
    expect(find.text('Choose what to practice'), findsOneWidget);
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });

  testWidgets('missing selected focus shows choose exam fallback',
      (tester) async {
    await AppPreferencesRepository(db).setSelectedExamId('removed');

    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your exam'), findsOneWidget);
    await tester.tap(find.text('Choose exam'));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });
}
