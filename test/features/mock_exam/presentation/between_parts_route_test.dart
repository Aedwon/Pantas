import 'dart:async';
import 'dart:convert';

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
    SampledMockSection(sectionId: 'one', name: 'Reading', questionIds: ['q1']),
    SampledMockSection(sectionId: 'two', name: 'Math', questionIds: ['q2']),
  ],
);
const _parts = [
  MockPersistedPart(name: 'Reading', startIndex: 0, count: 1, minutes: 1),
  MockPersistedPart(name: 'Math', startIndex: 1, count: 1, minutes: 1),
];

Future<_Fixture> _fixture(
  WidgetTester tester, {
  bool waiting = true,
  int elapsed = 60,
  bool strict = false,
  DateTime? backgroundedAt,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final content = openTestContentDatabase();
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
  final repo = _ControlledRepo(db);
  final now = DateTime.now();
  await repo.insertStart(
    MockAttemptStart(
      id: 'paper',
      userId: mockAttemptLocalUserId,
      examId: 'exam_cse',
      blueprintId: 'frozen',
      blueprintName: 'CSE',
      durationMinutes: 2,
      strictMode: strict,
      sampledQuestionsJson: _codec.encodeSample(
        _sample,
        currentPartIndex: waiting ? 1 : 0,
        partStartedAtSeconds: waiting ? elapsed : 0,
        partsTimedSeparately: true,
        parts: _parts,
        betweenParts: waiting,
        strictBackgroundedAt: backgroundedAt,
      ),
      startedAt: now.subtract(Duration(seconds: elapsed)),
    ),
  );
  await repo.flushProgress(
    attemptId: 'paper',
    elapsedSeconds: elapsed,
    accumulatedPausedSeconds: 0,
    pausedAtLastFlush: !waiting,
    answersJson: '{"q1":{"selectedIndex":0,"atSec":2}}',
    flagsJson: '["q1"]',
    currentIndex: waiting ? 1 : 0,
    flushedAt: now,
  );
  final router = GoRouter(
    initialLocation: '/mock',
    routes: [
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const Scaffold(body: Text('Quiz')),
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
  final result = _Fixture(repo, content, db, router);
  await tester.pumpWidget(result.widget);
  await tester.pumpAndSettle();
  return result;
}

class _Fixture {
  _Fixture(this.repo, this.content, this.db, this.router);
  final _ControlledRepo repo;
  final ContentDatabase content;
  final AppDatabase db;
  final GoRouter router;
  Widget get widget => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          mockAttemptRepoProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      );
  Future<MockSessionSnapshot> saved() async {
    final row = (await repo.findById('paper'))!;
    return _codec.decode(
      sampledQuestionsJson: row.sampledQuestionsJson,
      answersJson: row.answersJson,
      flagsJson: row.flagsJson,
    );
  }
}

class _ControlledRepo extends MockAttemptRepo {
  _ControlledRepo(super.db);
  Completer<void>? startGate;
  Completer<void>? waitGate;
  bool failStart = false;
  int startWrites = 0;
  final completed = <String>[];
  @override
  Future<void> flushProgress({
    required String attemptId,
    required int elapsedSeconds,
    required int accumulatedPausedSeconds,
    required bool pausedAtLastFlush,
    required String answersJson,
    required String flagsJson,
    required int currentIndex,
    required DateTime flushedAt,
    String? sampledQuestionsJson,
    bool updateSyncTimestamp = true,
  }) async {
    final metadata = sampledQuestionsJson == null
        ? null
        : ((jsonDecode(sampledQuestionsJson) as List<dynamic>).first
            as Map<String, dynamic>)['_session'] as Map<String, dynamic>;
    final previous = (await findById(attemptId))!;
    final wasWaiting = _codec
        .decode(
          sampledQuestionsJson: previous.sampledQuestionsJson,
          answersJson: previous.answersJson,
          flagsJson: previous.flagsJson,
        )
        .betweenParts;
    final starting = wasWaiting &&
        metadata?['currentPartIndex'] == 1 &&
        metadata?['betweenParts'] == false;
    if (metadata?['betweenParts'] == true) await waitGate?.future;
    if (starting) {
      startWrites++;
      await startGate?.future;
      if (failStart) throw StateError('controlled write failure');
    }
    await super.flushProgress(
      attemptId: attemptId,
      elapsedSeconds: elapsedSeconds,
      accumulatedPausedSeconds: accumulatedPausedSeconds,
      pausedAtLastFlush: pausedAtLastFlush,
      answersJson: answersJson,
      flagsJson: flagsJson,
      currentIndex: currentIndex,
      flushedAt: flushedAt,
      sampledQuestionsJson: sampledQuestionsJson,
      updateSyncTimestamp: updateSyncTimestamp,
    );
    completed.add(
      starting
          ? 'start'
          : metadata?['betweenParts'] == true
              ? 'wait'
              : 'progress',
    );
  }
}

void main() {
  testWidgets('saved transition reopens with its next part stopped',
      (tester) async {
    final fixture = await _fixture(tester);
    expect(find.byType(PartTransitionPage), findsOneWidget);
    expect(find.text('Question q2?'), findsNothing);
    await tester.pump(const Duration(seconds: 30));
    expect((await fixture.repo.findById('paper'))!.elapsedSeconds, 60);
    expect((await fixture.saved()).betweenParts, isTrue);
  });
  testWidgets('Start persists once before the next paper can accept progress',
      (tester) async {
    final fixture = await _fixture(tester);
    fixture.repo.startGate = Completer<void>();
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    expect(fixture.repo.startWrites, 1);
    expect((await fixture.saved()).betweenParts, isTrue);
    expect(find.text('Question q2?'), findsNothing);
    fixture.repo.startGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Question q2?'), findsOneWidget);
    expect((await fixture.saved()).betweenParts, isFalse);
    await tester.tap(find.text('Choice A'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(
      fixture.repo.completed.indexOf('start'),
      lessThan(fixture.repo.completed.lastIndexOf('progress')),
    );
  });
  testWidgets('failed Start keeps the saved transition and permits retry',
      (tester) async {
    final fixture = await _fixture(tester);
    fixture.repo.failStart = true;
    await tester.tap(find.text('Start Part 2'));
    await tester.pumpAndSettle();
    expect(find.byType(PartTransitionPage), findsOneWidget);
    expect((await fixture.saved()).betweenParts, isTrue);
    fixture.repo.failStart = false;
    await tester.tap(find.text('Start Part 2'));
    await tester.pumpAndSettle();
    expect(find.text('Question q2?'), findsOneWidget);
    expect((await fixture.saved()).flags, {'q1'});
  });
  testWidgets(
      'early ending persists actual next position and stopped transition',
      (tester) async {
    final fixture = await _fixture(tester, waiting: false, elapsed: 10);
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End Part 1'));
    await tester.pumpAndSettle();
    expect(find.byType(PartTransitionPage), findsOneWidget);
    final saved = await fixture.saved();
    expect(saved.betweenParts, isTrue);
    expect(saved.endedEarly, isTrue);
    expect(saved.currentPartIndex, 1);
    expect((await fixture.repo.findById('paper'))!.currentIndex, 1);
  });
  testWidgets('elapsed part persists transition before starting another part',
      (tester) async {
    final fixture = await _fixture(tester, waiting: false, elapsed: 59);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(PartTransitionPage), findsOneWidget);
    expect((await fixture.saved()).betweenParts, isTrue);
    expect((await fixture.saved()).endedEarly, isFalse);
    expect((await fixture.repo.findById('paper'))!.elapsedSeconds, 60);
  });
  testWidgets('background checkpoint accounts for all between-part wall time',
      (tester) async {
    final fixture = await _fixture(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    final row = (await fixture.repo.findById('paper'))!;
    expect(row.accumulatedPausedSeconds, greaterThanOrEqualTo(1));
    expect(row.elapsedSeconds, 60);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });
  testWidgets(
      'lifecycle flush cannot restore the gate behind acknowledged Start',
      (tester) async {
    final fixture = await _fixture(tester, strict: true);
    fixture.repo.startGate = Completer<void>();
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    fixture.repo.startGate!.complete();
    await tester.pumpAndSettle();
    final saved = await fixture.saved();
    expect(saved.betweenParts, isFalse);
    expect(saved.strictBackgroundedAt, isNotNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Question q2?'), findsOneWidget);
  });
  testWidgets('disposing during Start cannot restore an acknowledged gate',
      (tester) async {
    final fixture = await _fixture(tester);
    fixture.repo.startGate = Completer<void>();
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.repo.startGate!.complete();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump();
    expect((await fixture.saved()).betweenParts, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });
  testWidgets(
      'later successful lifecycle flush cannot acknowledge a failed Start',
      (tester) async {
    final fixture = await _fixture(tester);
    fixture.repo.startGate = Completer<void>();
    fixture.repo.failStart = true;
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    fixture.repo.startGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PartTransitionPage), findsOneWidget);
    expect(find.text('Question q2?'), findsNothing);
    expect((await fixture.saved()).betweenParts, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });
  testWidgets(
      'queued gate write finishes before explicit Start and new answers',
      (tester) async {
    final fixture = await _fixture(tester, waiting: false, elapsed: 10);
    fixture.repo.waitGate = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End Part 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    expect(fixture.repo.startWrites, 0);
    expect(find.byType(PartTransitionPage), findsOneWidget);
    fixture.repo.waitGate!.complete();
    await tester.pumpAndSettle();
    expect(
      fixture.repo.completed.indexOf('wait'),
      lessThan(fixture.repo.completed.indexOf('start')),
    );
    expect(find.text('Question q2?'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
  });
  testWidgets(
      'time expiry before strict grace scores completion instead of forfeit',
      (tester) async {
    final fixture = await _fixture(
      tester,
      waiting: false,
      strict: true,
      elapsed: 150,
      backgroundedAt: DateTime.now().subtract(const Duration(seconds: 20)),
    );
    expect(find.text('Results'), findsOneWidget);
    expect(
      (await fixture.repo.findById('paper'))!.status,
      MockAttemptStatus.completed,
    );
    expect((await fixture.repo.findById('paper'))!.scoreRaw, 1);
  });
  testWidgets('strict background forfeit is not bypassed by a saved transition',
      (tester) async {
    final fixture = await _fixture(
      tester,
      strict: true,
      backgroundedAt: DateTime.now().subtract(const Duration(seconds: 20)),
    );
    expect(find.text('Results'), findsOneWidget);
    expect(
      (await fixture.repo.findById('paper'))!.status,
      MockAttemptStatus.forfeited,
    );
  });
}
