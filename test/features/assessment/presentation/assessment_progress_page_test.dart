import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/assessment/application/assessment_progress_providers.dart';
import 'package:pantas/features/assessment/data/assessment_progress_store.dart';
import 'package:pantas/features/assessment/domain/models/assessment_progress.dart';
import 'package:pantas/features/assessment/presentation/assessment_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/assessment/e1',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
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

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late AssessmentProgressStore store;
  const uid = 'u1';

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    store = AssessmentProgressStore(AppPreferencesRepository(db));
    await SyncActiveContextStore(db)
        .publishStable(uid: uid, generationId: 'g1');
    await seedContentExam(contentDb, examId: 'e1', code: 'CSE', name: 'CSE');
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
    for (final id in ['q1', 'q2', 'q3']) {
      await seedContentQuestion(
        contentDb,
        questionId: id,
        topicId: 't1',
        examId: 'e1',
        stem: 'Stem of $id?',
        correctText: 'Option A',
        wrongText: 'Option B',
      );
    }
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  List<Override> overrides() => [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ];

  Future<void> open(WidgetTester tester) async {
    await tester.pumpAppWithRouter(_router(), overrides: overrides());
    await tester.pumpAndSettle();
  }

  AssessmentProgress saved(
    List<String> ids,
    Map<String, String> picks,
  ) =>
      AssessmentProgress(
        examId: 'e1',
        attemptId: 'attempt-1',
        startedAt: DateTime.utc(2026, 11, 26),
        questionIds: ids,
        picks: picks,
        responseMs: {for (final id in picks.keys) id: 900},
      );

  testWidgets('a pick is saved at once, before Next', (tester) async {
    await open(tester);
    expect(await store.load(uid, 'e1'), isNull);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    final progress = await store.load(uid, 'e1');
    expect(progress, isNotNull);
    expect(progress!.questionIds, hasLength(3));
    expect(progress.questionIds.toSet(), {'q1', 'q2', 'q3'});
    expect(progress.picks, hasLength(1));
    expect(progress.picks.keys.single, progress.questionIds.first);
    expect(progress.attemptId, isNotEmpty);
    expect(progress.answered, 1);
  });

  testWidgets('changing a pick replaces it', (tester) async {
    await open(tester);
    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();
    final progress = await store.load(uid, 'e1');
    expect(progress!.picks, hasLength(1));
    expect(progress.picks.values.single, endsWith('_b'));
  });

  testWidgets('opening with saved progress resumes the same list and picks',
      (tester) async {
    await store.save(
      uid,
      saved(['q3', 'q1', 'q2'], {'q3': 'q3_b', 'q1': 'q1_a'}),
    );
    await open(tester);

    // The first question with no pick, in the saved order, not a new draw.
    expect(find.text('Stem of q2?'), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);
    final after = await store.load(uid, 'e1');
    expect(after!.attemptId, 'attempt-1');
    expect(after.questionIds, ['q3', 'q1', 'q2']);
    expect(after.picks, {'q3': 'q3_b', 'q1': 'q1_a'});
  });

  testWidgets('a saved question no longer in the bank is dropped',
      (tester) async {
    await store.save(
      uid,
      saved(['q1', 'gone', 'q2', 'q3'], {'q1': 'q1_a', 'gone': 'gone_a'}),
    );
    await open(tester);

    expect(find.text('Stem of q2?'), findsOneWidget);
    expect(find.text('2 of 3'), findsOneWidget);
    final after = await store.load(uid, 'e1');
    expect(after!.questionIds, ['q1', 'q2', 'q3']);
    expect(after.picks, {'q1': 'q1_a'});
  });

  testWidgets('if no saved question remains the assessment starts fresh',
      (tester) async {
    await store.save(uid, saved(['gone1', 'gone2'], {'gone1': 'x'}));
    await open(tester);

    expect(find.text('1 of 3'), findsOneWidget);
    // Nothing is kept until the first pick.
    expect(await store.load(uid, 'e1'), isNull);
    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    final after = await store.load(uid, 'e1');
    expect(after!.attemptId, isNot('attempt-1'));
    expect(after.questionIds.toSet(), {'q1', 'q2', 'q3'});
    expect(after.picks, hasLength(1));
  });

  testWidgets('leaving keeps the picks and Home sees them', (tester) async {
    await open(tester);
    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(navigator.maybePop());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final progress =
        await container.read(assessmentProgressProvider('e1').future);
    expect(progress!.answered, 1);
    expect(progress.total, 3);
  });

  testWidgets('saving the result clears the saved progress', (tester) async {
    await store.save(
      uid,
      saved(['q1', 'q2', 'q3'], {'q1': 'q1_a', 'q2': 'q2_a'}),
    );
    await open(tester);
    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(await store.load(uid, 'e1'), isNull);
  });
}
