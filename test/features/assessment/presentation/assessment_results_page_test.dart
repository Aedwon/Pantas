import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't2',
            subjectId: 's1',
            name: 'Reading Comprehension',
            ordering: 2,
          ),
        );

    // t1: 0/3 = 0% (weak), t2: 3/3 = 100% (strong)
    await AssessmentRepository(db).saveResult('e1', DateTime(2026), [
      const TopicScore(topicId: 't1', correct: 0, total: 3),
      const TopicScore(topicId: 't2', correct: 3, total: 3),
    ]);
  });

  tearDown(() => db.close());

  testWidgets('shows topic bars sorted weakest-first', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
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
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Civil Service Exam profile'), findsOneWidget);
  });

  testWidgets('weak topic shows Start here badge', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Start here'), findsOneWidget);
  });

  testWidgets('focus row opens lessons using study route', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start here'));
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
  });

  testWidgets('Start studying opens the weakest topic lessons', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start studying'));
    await tester.tap(find.text('Start studying'));
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
  });
}
