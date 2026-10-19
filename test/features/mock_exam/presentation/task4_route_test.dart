import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';

import '../../../helpers/in_memory_database.dart';

const _codec = MockSessionSnapshotCodec();
const _sample = MockSample(
  expectedQuestionCount: 2,
  sections: [
    SampledMockSection(
      sectionId: 'gi',
      name: 'General Information',
      questionIds: ['q1', 'q2'],
    ),
  ],
);

class _Fixture {
  _Fixture(this.db, this.content, this.router);
  final AppDatabase db;
  final ContentDatabase content;
  final GoRouter router;

  Widget get widget => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      );
}

Future<_Fixture> _open(
  WidgetTester tester, {
  String? sampledJson,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final content = openTestContentDatabase();
  addTearDown(content.close);
  await seedContentExam(content, examId: 'exam_cse');
  await seedContentSubject(content, subjectId: 'subject', examId: 'exam_cse');
  await seedContentTopic(content, topicId: 'topic', subjectId: 'subject');
  for (final id in ['q1', 'q2']) {
    await seedContentQuestion(
      content,
      questionId: id,
      topicId: 'topic',
      examId: 'exam_cse',
    );
  }
  await AppPreferencesRepository(db).setSelectedExamId('exam_cse');
  await MockAttemptRepo(db).insertStart(
    MockAttemptStart(
      id: 'paper',
      userId: mockAttemptLocalUserId,
      examId: 'exam_cse',
      blueprintId: 'cse',
      blueprintName: 'CSE',
      durationMinutes: 60,
      strictMode: false,
      sampledQuestionsJson: sampledJson ??
          _codec.encodeSample(
            _sample,
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
      startedAt: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
  );
  final router = GoRouter(
    initialLocation: '/mock',
    routes: [
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const Scaffold(body: Text('Quiz tab')),
      ),
      GoRoute(
        path: '/mock',
        builder: (_, __) =>
            const MockStartRoute.resume(resumeAttemptId: 'paper'),
      ),
      GoRoute(
        path: '/mock/results/:id',
        builder: (_, __) => const Scaffold(body: Text('Results')),
      ),
    ],
  );
  addTearDown(router.dispose);
  final fixture = _Fixture(db, content, router);
  await tester.pumpWidget(fixture.widget);
  await tester.pumpAndSettle();
  return fixture;
}

void main() {
  testWidgets('a one-block paper names each question by its subject',
      (tester) async {
    await _open(tester);
    expect(find.text('GENERAL INFORMATION'), findsOneWidget);
  });

  testWidgets('the grid submits a one-block paper as a manual submission',
      (tester) async {
    final fixture = await _open(tester);
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit the Exam'));
    await tester.pumpAndSettle();
    expect(find.text('Submit the exam?'), findsOneWidget);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsOneWidget);
    final row = await MockAttemptRepo(fixture.db).findById('paper');
    expect(row!.status, MockAttemptStatus.completed);
  });

  testWidgets('discarding a broken saved mock leaves by the declared route',
      (tester) async {
    await _open(tester, sampledJson: 'not json');
    expect(find.text('Discard saved mock'), findsOneWidget);
    await tester.tap(find.text('Discard saved mock'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz tab'), findsOneWidget);
  });
}
