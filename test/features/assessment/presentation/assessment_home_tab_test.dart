import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_home_tab.dart';
import 'package:cse_cet_reviewer/features/metrics/atoms/home_atom_chip.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/home_atom_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => AssessmentHomeTab(
            afterHeaderBuilder: (_, ref, examId) {
              final now = DateTime.now();
              final localDate = DateTime(now.year, now.month, now.day);
              final atom = ref.watch(
                homeAtomProvider(
                  HomeAtomRequest(
                    examId: examId,
                    userId: 'local',
                    localDate: localDate,
                    now: localDate.add(
                      const Duration(hours: 23, minutes: 59),
                    ),
                  ),
                ),
              );
              return atom.maybeWhen(
                data: (chip) => chip == null
                    ? const SizedBox.shrink()
                    : HomeAtomChip(chip: chip),
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const Scaffold(body: Text('Onboarding')),
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

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Choose exam'), findsWidgets);
    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.text('Pick the exam you are reviewing for.'), findsOneWidget);

    await tester.tap(find.text('Choose exam').last);
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('no assessment shows focused hero and CTAs', (tester) async {
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

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Civil Service Exam'), findsOneWidget);
    expect(find.byType(HomeAtomChip), findsOneWidget);
    expect(find.text('Build your study plan'), findsOneWidget);
    expect(
      find.text('Take the assessment to find what to study first.'),
      findsOneWidget,
    );
    expect(find.text('Start assessment'), findsOneWidget);
    expect(find.text('Quiz for now'), findsOneWidget);

    await tester.tap(find.text('Start assessment'));
    await tester.pumpAndSettle();
    expect(find.text('Assessment cse'), findsOneWidget);
  });

  testWidgets('quiz for now opens quick quiz for selected exam',
      (tester) async {
    await insertExam(id: 'cse', name: 'Civil Service Exam');
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    await pumpHome(tester);

    await tester.tap(find.text('Quiz for now'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz cse '), findsOneWidget);
  });

  testWidgets('completed weak results show study plan rows', (tester) async {
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

    expect(find.text('Assessment last taken on May 12, 2026'), findsOneWidget);
    expect(find.text('Your study plan'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Logic'), findsNothing);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Study'), findsNWidgets(3));
    expect(find.text('View full results'), findsOneWidget);
  });

  testWidgets('all strong results show keep sharp and quiz actions',
      (tester) async {
    await insertExam(id: 'upcat', name: 'UPCAT');
    await insertTopic(
      id: 'algebra',
      subjectId: 's1',
      name: 'Algebra',
      ordering: 1,
    );
    await insertTopic(
      id: 'geometry',
      subjectId: 's1',
      name: 'Geometry',
      ordering: 2,
    );
    await insertTopic(
      id: 'biology',
      subjectId: 's1',
      name: 'Biology',
      ordering: 3,
    );
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    await AssessmentRepository(db).saveResult(
      'upcat',
      DateTime(2026, 5, 12),
      const [
        TopicScore(topicId: 'algebra', correct: 78, total: 100),
        TopicScore(topicId: 'geometry', correct: 82, total: 100),
        TopicScore(topicId: 'biology', correct: 85, total: 100),
      ],
    );

    await pumpHome(tester);

    expect(find.text('Keep sharp'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Quiz'), findsNWidgets(3));
  });

  testWidgets('study plan row navigates to expected study route',
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

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(find.text('Study vocab cse'), findsOneWidget);
  });

  testWidgets('view full results navigates to assessment results route',
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

    await tester.tap(find.text('View full results'));
    await tester.pumpAndSettle();
    expect(find.text('Results cse'), findsOneWidget);
  });
}
