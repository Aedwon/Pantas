import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';

import '../../../helpers/in_memory_database.dart';

const _codec = MockSessionSnapshotCodec();
const _sample = MockSample(
  expectedQuestionCount: 2,
  sections: [
    SampledMockSection(sectionId: 'one', name: 'Reading', questionIds: ['q1']),
    SampledMockSection(sectionId: 'two', name: 'Math', questionIds: ['q2']),
  ],
);
const _parts = [
  MockPersistedPart(name: 'Reading', startIndex: 0, count: 1, minutes: 1),
  MockPersistedPart(name: 'Math', startIndex: 1, count: 1, minutes: 1),
];

/// Part 2 of a strict two-part paper runs from 60s to 120s of the clock while
/// the whole paper has ten minutes. Part 1 was ended early, so the overall
/// budget is far later than the part that is actually running.
Future<MockAttemptRepo> _open(
  WidgetTester tester, {
  required Duration closedFor,
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
  final repo = MockAttemptRepo(db);
  final now = DateTime.now();
  await repo.insertStart(
    MockAttemptStart(
      id: 'paper',
      userId: mockAttemptLocalUserId,
      examId: 'exam_cse',
      blueprintId: 'frozen',
      blueprintName: 'Sectional',
      durationMinutes: 10,
      strictMode: true,
      sampledQuestionsJson: _codec.encodeSample(
        _sample,
        currentPartIndex: 1,
        partStartedAtSeconds: 60,
        partsTimedSeparately: true,
        parts: _parts,
        strictBackgroundedAt: now.subtract(closedFor),
      ),
      // Part 2 ended 10 seconds ago.
      startedAt: now.subtract(const Duration(seconds: 130)),
    ),
  );
  await repo.flushProgress(
    attemptId: 'paper',
    elapsedSeconds: 100,
    accumulatedPausedSeconds: 0,
    pausedAtLastFlush: false,
    answersJson: '{"q1":{"selectedIndex":0,"atSec":2}}',
    flagsJson: '[]',
    currentIndex: 1,
    flushedAt: now.subtract(closedFor),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
      ],
      child: MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets(
      'a last part that ran out before the grace ended is completed, not '
      'forfeited', (tester) async {
    // Left 12 seconds ago: the 10 second grace would end 2 seconds ago, which
    // is after the part ran out 10 seconds ago.
    final repo = await _open(tester, closedFor: const Duration(seconds: 12));
    expect(find.text('Results'), findsOneWidget);
    expect(
      (await repo.findById('paper'))!.status,
      MockAttemptStatus.completed,
    );
  });

  testWidgets('leaving longer than the grace before the part ended forfeits',
      (tester) async {
    // Left 30 seconds ago: the grace ended 20 seconds ago, before the part
    // would have run out.
    final repo = await _open(tester, closedFor: const Duration(seconds: 30));
    expect(find.text('Results'), findsOneWidget);
    expect(
      (await repo.findById('paper'))!.status,
      MockAttemptStatus.forfeited,
    );
  });
}
