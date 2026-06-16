import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_home_tab.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const AssessmentHomeTab(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const Scaffold(body: Text('Onboarding')),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('Settings page')),
        ),
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, state) => Scaffold(
            body: Text('Assessment ${state.pathParameters['examId']}'),
          ),
          routes: [
            GoRoute(
              path: 'results',
              builder: (_, state) => Scaffold(
                body: Text('Results ${state.pathParameters['examId']}'),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/quiz/quick/:examId',
          builder: (_, state) => Scaffold(
            body: Text(
              'Quiz ${state.pathParameters['examId']} '
              '${state.uri.queryParameters['topicId'] ?? ''}',
            ),
          ),
        ),
        GoRoute(
          path: '/study/topic/:topicId',
          builder: (_, state) => Scaffold(
            body: Text(
              'Study ${state.pathParameters['topicId']} '
              '${state.uri.queryParameters['examId'] ?? ''}',
            ),
          ),
        ),
      ],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> insertExam({
    required String id,
    required String name,
    String subjectId = 's1',
  }) async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: id,
            code: id.toUpperCase(),
            name: name,
            shortName: id.toUpperCase(),
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: subjectId,
            examId: id,
            name: 'General',
            ordering: 1,
          ),
        );
  }

  Future<void> insertTopic({
    required String id,
    required String subjectId,
    required String name,
    required int ordering,
  }) async {
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name,
            ordering: ordering,
          ),
        );
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('missing focus shows choose exam fallback', (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await insertExam(id: 'upcat', name: 'UPCAT', subjectId: 's2');

    await pumpHome(tester);

    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('Pick the exam you are reviewing for.'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('no assessment shows greeting header, Lately line, and CTAs',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    final base = DateTime.now().subtract(const Duration(days: 1));
    final sharpHour = DateTime(base.year, base.month, base.day, 21);
    for (var i = 0; i < 7; i += 1) {
      await db.into(db.quizSessions).insert(
            QuizSessionsCompanion.insert(
              id: 'session_$i',
              userId: 'local',
              examId: 'cse',
              origin: 'today_topic',
              questionIdsJson: '[]',
              currentIndex: const Value(10),
              correctCount: const Value(8),
              startedAt: sharpHour,
              completedAt: Value(sharpHour.add(const Duration(minutes: 10))),
            ),
          );
    }

    await pumpHome(tester);

    expect(find.textContaining('Magandang'), findsOneWidget);
    expect(find.text('CSE'), findsOneWidget);
    expect(find.textContaining('Lately — '), findsOneWidget);
    expect(find.text('Build your study plan'), findsOneWidget);
    expect(
      find.text('Take the assessment to find what to study first.'),
      findsOneWidget,
    );
    expect(find.byType(StatsBand), findsNothing);

    await tester.tap(find.text('Start the assessment'));
    await tester.pumpAndSettle();
    expect(find.text('Assessment cse'), findsOneWidget);
  });

  testWidgets('quick quiz CTA opens quick quiz for selected exam',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    await pumpHome(tester);

    await tester.tap(find.text('Try a quick quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz cse '), findsOneWidget);
  });

  testWidgets('gear pushes settings route', (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    await pumpHome(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings page'), findsOneWidget);
  });

  testWidgets('completed results show stats band and focus topic rows',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await insertTopic(
      id: 'vocab',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    );
    await insertTopic(
      id: 'grammar',
      subjectId: 's1',
      name: 'Grammar',
      ordering: 2,
    );
    await insertTopic(
      id: 'reading',
      subjectId: 's1',
      name: 'Reading',
      ordering: 3,
    );
    await insertTopic(
      id: 'logic',
      subjectId: 's1',
      name: 'Logic',
      ordering: 4,
    );
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AssessmentRepository(db).saveResult(
      'cse',
      DateTime(2026, 5, 12),
      const [
        TopicScore(topicId: 'vocab', correct: 0, total: 3),
        TopicScore(topicId: 'grammar', correct: 1, total: 3),
        TopicScore(topicId: 'reading', correct: 2, total: 5),
        TopicScore(topicId: 'logic', correct: 4, total: 5),
      ],
    );

    await pumpHome(tester);

    expect(find.byType(StatsBand), findsOneWidget);
    // 7 correct of 16 questions → 44%; only logic (80%) is strong.
    expect(find.text('44%'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('/4'), findsOneWidget);
    expect(find.text('Focus topics'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Logic'), findsNothing);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Continue studying'), findsOneWidget);
    expect(find.text('View results'), findsOneWidget);
  });

  testWidgets('focus topic row navigates to expected study route',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await insertTopic(
      id: 'vocab',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    );
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AssessmentRepository(db).saveResult(
      'cse',
      DateTime(2026, 5, 12),
      const [TopicScore(topicId: 'vocab', correct: 0, total: 3)],
    );

    await pumpHome(tester);

    await tester.tap(find.text('Vocabulary'));
    await tester.pumpAndSettle();
    expect(find.text('Study vocab cse'), findsOneWidget);
  });

  testWidgets('strong topic row navigates to quick quiz route', (tester) async {
    await insertExam(id: 'upcat', name: 'UPCAT');
    await insertTopic(
      id: 'algebra',
      subjectId: 's1',
      name: 'Algebra',
      ordering: 1,
    );
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await AssessmentRepository(db).saveResult(
      'upcat',
      DateTime(2026, 5, 12),
      const [TopicScore(topicId: 'algebra', correct: 78, total: 100)],
    );

    await pumpHome(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz upcat algebra'), findsOneWidget);
  });

  testWidgets('view results navigates to assessment results route',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await insertTopic(
      id: 'vocab',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    );
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AssessmentRepository(db).saveResult(
      'cse',
      DateTime(2026, 5, 12),
      const [TopicScore(topicId: 'vocab', correct: 0, total: 3)],
    );

    await pumpHome(tester);

    await tester.tap(find.text('View results'));
    await tester.pumpAndSettle();
    expect(find.text('Results cse'), findsOneWidget);
  });
}
